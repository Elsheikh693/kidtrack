import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../Data/models/classroom/classroom_model.dart';
import '../../Data/models/schedule/schedule_model.dart';
import '../../presentation/screens/manager/dashboard/models/late_session_entry.dart';
import 'late_session_settings_service.dart';
import 'session_service.dart';

/// Live watcher powering the manager dashboard's "late session" card. Every
/// minute it cross-references today's timetable slots for the manager's branch
/// against the activities actually started, and lists any slot whose start time
/// (+grace) has passed while the classroom still has nothing running — the same
/// signal the `lateSessionStartScan` Cloud Function pushes when the app is shut.
class LateSessionMonitorService extends GetxService {
  final lateSessions = <LateSessionEntry>[].obs;

  Timer? _ticker;
  bool _started = false;

  // Static-ish caches, refreshed on start()/refresh().
  final _classrooms = <ClassroomModel>[];
  final _slots = <ScheduleModel>[]; // today's slots for branch classrooms
  final _teacherNames = <String, String>{}; // uid → name
  final _subjectNames = <String, String>{}; // id → name

  LateSessionSettingsService get _settings =>
      Get.find<LateSessionSettingsService>();
  SessionService get _session => SessionService();

  String get _nurseryId => _session.nurseryId ?? '';
  DatabaseReference _ref(String path) =>
      FirebaseDatabase.instance.ref('platform/$_nurseryId/$path');

  static const _dayKeys = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _settings.load();
    await refresh();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  /// Reloads the static caches (classrooms/staff/subjects/today's slots) then
  /// recomputes. Call after the manager edits the timetable.
  Future<void> refresh() async {
    if (_nurseryId.isEmpty) return;
    await Future.wait([
      _loadClassrooms(),
      _loadTeacherNames(),
      _loadSubjectNames(),
    ]);
    await _loadTodaySlots();
    await _tick();
  }

  Future<void> _tick() async {
    if (!_settings.enabled.value || _slots.isEmpty) {
      lateSessions.clear();
      return;
    }
    final fulfilled = await _fulfilledToday();
    final presentStaff = await _presentStaffToday();
    final grace = _settings.graceMinutes.value;
    final nowMin = _nowMinutes();

    final result = <LateSessionEntry>[];
    for (final s in _slots) {
      final startMin = _toMinutes(s.startTime);
      final endMin = _toMinutes(s.endTime);
      if (startMin == null || endMin == null) continue;
      // Only within the slot's own window: past the grace, before it ends.
      if (nowMin < startMin + grace) continue;
      if (nowMin >= endMin) continue;
      // Already started (matched by slot id, or by subject as a fallback).
      if (fulfilled.slotIds.contains(s.key)) continue;
      if (s.subjectId != null && fulfilled.subjectIds.contains(s.subjectId)) {
        continue;
      }
      // If we know the assigned teacher is absent today, it's an attendance
      // issue — not a late start. Unknown presence is treated as present.
      final teacherId = _effectiveTeacher(s);
      if (presentStaff != null &&
          teacherId.isNotEmpty &&
          !presentStaff.contains(teacherId)) {
        continue;
      }
      result.add(LateSessionEntry(
        slotId: s.key ?? '',
        classroomId: s.classroomId,
        classroomName: _classroomName(s.classroomId),
        title: _slotTitle(s),
        teacherId: teacherId,
        teacherName: _teacherNames[teacherId] ?? '',
        startTime: s.startTime,
        minutesLate: nowMin - startMin,
      ));
    }
    result.sort((a, b) => b.minutesLate.compareTo(a.minutesLate));
    lateSessions.assignAll(result);
  }

  /// Manager taps "nudge the teacher": writes a nudge intent the
  /// `onTeacherNudgeCreated` Cloud Function turns into an FCM push to the
  /// teacher. The client never sends FCM directly.
  Future<bool> nudgeTeacher(LateSessionEntry entry) async {
    if (_nurseryId.isEmpty || entry.teacherId.isEmpty) return false;
    try {
      final ref = _ref('teacherNudges').push();
      await ref.set({
        'teacherId': entry.teacherId,
        'classroomId': entry.classroomId,
        'slotId': entry.slotId,
        'title': entry.title,
        'byManagerId': _session.userId ?? '',
        'createdAt': ServerValue.timestamp,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Loads ───────────────────────────────────────────────────────────────────

  Future<void> _loadClassrooms() async {
    _classrooms.clear();
    final snap = await _ref('classrooms').get();
    if (snap.value is! Map) return;
    for (final e in (snap.value as Map).entries) {
      if (e.value is! Map) continue;
      final c = ClassroomModel.fromJson(
        Map<String, dynamic>.from(e.value as Map),
        key: e.key.toString(),
      );
      if (_session.seesAnyBranch(c.scopeBranches)) _classrooms.add(c);
    }
  }

  Future<void> _loadTodaySlots() async {
    _slots.clear();
    if (_classrooms.isEmpty) return;
    final ids = _classrooms.map((c) => c.key).whereType<String>().toSet();
    final today = _todayKey();
    final snap = await _ref('schedules').get();
    if (snap.value is! Map) return;
    for (final e in (snap.value as Map).entries) {
      if (e.value is! Map) continue;
      final s = ScheduleModel.fromJson(
        Map<String, dynamic>.from(e.value as Map),
        key: e.key.toString(),
      );
      if (s.day == today && ids.contains(s.classroomId)) _slots.add(s);
    }
  }

  Future<void> _loadTeacherNames() async {
    _teacherNames.clear();
    final snap = await _ref('staff').get();
    if (snap.value is! Map) return;
    for (final e in (snap.value as Map).entries) {
      if (e.value is! Map) continue;
      final m = Map<String, dynamic>.from(e.value as Map);
      final uid = m['uid']?.toString() ?? e.key.toString();
      final name = m['name']?.toString() ?? '';
      if (uid.isNotEmpty) _teacherNames[uid] = name;
    }
  }

  Future<void> _loadSubjectNames() async {
    _subjectNames.clear();
    final snap = await _ref('subjects').get();
    if (snap.value is! Map) return;
    for (final e in (snap.value as Map).entries) {
      if (e.value is! Map) continue;
      final m = Map<String, dynamic>.from(e.value as Map);
      _subjectNames[e.key.toString()] = m['name']?.toString() ?? '';
    }
  }

  /// Slot ids + subject ids of activities started today across branch classrooms.
  Future<({Set<String> slotIds, Set<String> subjectIds})>
      _fulfilledToday() async {
    final slotIds = <String>{};
    final subjectIds = <String>{};
    final dayStart = _dayStartMs();
    await Future.wait(_classrooms.map((c) async {
      final cid = c.key ?? '';
      if (cid.isEmpty) return;
      final snap = await _ref('classroomActivities/$cid').get();
      if (snap.value is! Map) return;
      for (final e in (snap.value as Map).entries) {
        if (e.value is! Map) continue;
        final m = Map<String, dynamic>.from(e.value as Map);
        final started = _asInt(m['startedAt']) ?? 0;
        if (started < dayStart) continue;
        final slotId = m['scheduleSlotId']?.toString();
        if (slotId != null && slotId.isNotEmpty) slotIds.add(slotId);
        final subId = m['subjectId']?.toString();
        if (subId != null && subId.isNotEmpty) subjectIds.add(subId);
      }
    }));
    return (slotIds: slotIds, subjectIds: subjectIds);
  }

  /// Staff ids present (or late) today, or null when attendance wasn't taken.
  Future<Set<String>?> _presentStaffToday() async {
    final today = _todayDate();
    final snap = await _ref('staffAttendance').get();
    if (snap.value is! Map) return null;
    final present = <String>{};
    var sawToday = false;
    for (final e in (snap.value as Map).entries) {
      if (e.value is! Map) continue;
      final m = Map<String, dynamic>.from(e.value as Map);
      if (m['date']?.toString() != today) continue;
      sawToday = true;
      final status = m['status']?.toString() ?? 'present';
      final checkedIn = m['checkInTime'] != null;
      if (status != 'absent' && status != 'on_leave' && checkedIn) {
        present.add(m['staffId']?.toString() ?? '');
      }
    }
    return sawToday ? present : null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _effectiveTeacher(ScheduleModel s) {
    if (s.teacherId != null && s.teacherId!.isNotEmpty) return s.teacherId!;
    final c = _classrooms.firstWhereOrNull((c) => c.key == s.classroomId);
    return c?.teacherId ?? '';
  }

  String _classroomName(String id) =>
      _classrooms.firstWhereOrNull((c) => c.key == id)?.name ?? '';

  String _slotTitle(ScheduleModel s) {
    final topic = s.topic?.trim() ?? '';
    if (topic.isNotEmpty) return topic;
    final sub = _subjectNames[s.subjectId];
    if (sub != null && sub.isNotEmpty) return sub;
    return s.startTime;
  }

  String _todayKey() => _dayKeys[(DateTime.now().weekday - 1) % 7];

  String _todayDate() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  int _nowMinutes() {
    final n = DateTime.now();
    return n.hour * 60 + n.minute;
  }

  int _dayStartMs() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).millisecondsSinceEpoch;
  }

  static int? _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
