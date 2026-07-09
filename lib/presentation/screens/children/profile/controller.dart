import '../../../../index/index_main.dart';
import '../../../../Global/services/parent_education_service.dart';

class ChildProfileController extends GetxController {
  final child      = Rx<ChildModel?>(null);
  final parents    = <ParentModel>[].obs;
  final enrollment = Rx<EnrollmentModel?>(null);
  final classroom  = Rx<ClassroomModel?>(null);

  // Attendance + activities + teacher notes, all scoped to the active window.
  final recentAttendance = <ChildAttendanceModel>[].obs;
  final activities = <ClassroomActivityModel>[].obs;
  final homework   = <HomeworkModel>[].obs;
  final teacherNotes = <NoteModel>[].obs;

  final isLoading = true.obs;
  final isRangeLoading = false.obs;

  // ─── Filter ───────────────────────────────────────────────────────────────
  // One window drives BOTH the absences row and the activities list. The user
  // browses backwards a day or a week at a time, or jumps straight to any date
  // via the picker; `anchorDate` is the last day shown, the window spans back
  // from it. Defaults to a single DAY so the manager reads one focused day
  // (a whole week at once was too much noise).
  final filterByWeek = false.obs;
  final anchorDate = DateTime.now().obs;

  late final ChildParentService          _childSvc;
  late final GuardianParentService       _parentSvc;
  late final ParentChildParentService    _linkSvc;
  late final EnrollmentParentService     _enrollSvc;
  late final ClassroomParentService      _classroomSvc;
  late final ChildAttendanceParentService  _attendSvc;
  late final ChildWithdrawalService      _withdrawalSvc;

  final _activitySvc = TeacherActivityService();
  final _eduSvc = ParentEducationService();
  final _session = SessionService();

  String get childId =>
      (Get.arguments is Map) ? ((Get.arguments as Map)['childId'] ?? '') : '';

  // ─── Computed ─────────────────────────────────────────────────────────────

  String get childName => child.value != null
      ? '${child.value!.firstName} ${child.value!.lastName}'
      : '';

  /// Weekly day off. Friday only for now (official holidays: TODO calendar).
  static bool _isWeekend(DateTime d) => d.weekday == DateTime.friday;

  String get _nurseryId => _session.nurseryId ?? '';
  String get _classroomId =>
      enrollment.value?.classroomId ?? child.value?.classroomId ?? '';

  int get _spanDays => filterByWeek.value ? 7 : 1;

  DateTime get _anchorDay {
    final a = anchorDate.value;
    return DateTime(a.year, a.month, a.day);
  }

  DateTime get _windowStart => _anchorDay.subtract(Duration(days: _spanDays - 1));
  int get _startMs => _windowStart.millisecondsSinceEpoch;
  // End of the anchor day (exclusive boundary, minus 1ms to stay inclusive).
  int get _endMs =>
      _anchorDay.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;

  bool get canGoForward => _anchorDay.isBefore(_today);
  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Human label for the current window, e.g. "20 يونيو" or "14 – 20 يونيو".
  String get rangeLabel {
    if (!filterByWeek.value) return _dayLabel(_anchorDay);
    final start = _windowStart;
    final end = _anchorDay;
    if (start.month == end.month) {
      return '${start.day} – ${end.day} ${_arMonth(end)}';
    }
    return '${_dayLabel(start)} – ${_dayLabel(end)}';
  }

  /// Derived per-day attendance status across the window (oldest → newest).
  /// Status: present | late | absent | holiday | not_arrived | future.
  List<MapEntry<String, String>> get windowDaysStatus {
    final todayKey = _dateStr(DateTime.now());
    final result = <MapEntry<String, String>>[];
    for (int i = _spanDays - 1; i >= 0; i--) {
      final d = _anchorDay.subtract(Duration(days: i));
      final key = _dateStr(d);
      final rec = recentAttendance.where((a) => a.date == key).firstOrNull;
      if (d.isAfter(_today)) {
        result.add(MapEntry(key, 'future'));
      } else if (rec != null) {
        result.add(MapEntry(key, rec.status));
      } else if (_isWeekend(d)) {
        result.add(MapEntry(key, 'holiday'));
      } else if (key == todayKey) {
        result.add(MapEntry(key, 'not_arrived'));
      } else {
        result.add(MapEntry(key, 'absent'));
      }
    }
    return result;
  }

  /// Number of absent school days in the current window.
  int get absentCount =>
      windowDaysStatus.where((e) => e.value == 'absent').length;

  ChildAttendanceModel? get todayRecord {
    final today = _dateStr(DateTime.now());
    return recentAttendance.where((a) => a.date == today).firstOrNull;
  }

  /// Homework attached to a given activity — matched by activityId first, then
  /// by subject as a fallback for homework created without an activity link.
  List<HomeworkModel> homeworkForActivity(ClassroomActivityModel a) {
    return homework.where((h) {
      if (h.activityId != null && h.activityId!.isNotEmpty && a.key != null) {
        return h.activityId == a.key;
      }
      if (h.subjectId != null && h.subjectId!.isNotEmpty && a.subjectId != null) {
        return h.subjectId == a.subjectId;
      }
      return false;
    }).toList();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _childSvc     = Get.find<ChildParentService>();
    _parentSvc    = Get.find<GuardianParentService>();
    _linkSvc      = Get.find<ParentChildParentService>();
    _enrollSvc    = Get.find<EnrollmentParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _attendSvc    = Get.find<ChildAttendanceParentService>();
    _withdrawalSvc = Get.find<ChildWithdrawalService>();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    // Reset so a reused (fenix) controller never flashes the previous child.
    child.value = null;
    parents.clear();
    enrollment.value = null;
    classroom.value = null;
    recentAttendance.clear();
    activities.clear();
    homework.clear();
    teacherNotes.clear();
    // Controller is a fenix singleton reused across opens — force the focused
    // single-day view on every open (don't inherit a previous week selection).
    filterByWeek.value = false;
    anchorDate.value = DateTime.now();
    // The child must load first — parent/class lookups fall back to fields on
    // child.value. Then resolve the classroom before the ranged reads, which
    // need its id.
    await _loadChild();
    if (child.value == null) { isLoading.value = false; return; }
    await Future.wait([
      _loadParent(),
      _loadEnrollmentAndClass(),
    ]);
    await _loadRange();
    isLoading.value = false;
  }

  // ─── Filter actions ─────────────────────────────────────────────────────────

  Future<void> setWeekMode(bool week) async {
    if (filterByWeek.value == week) return;
    filterByWeek.value = week;
    await _loadRange();
  }

  Future<void> stepBack() async {
    anchorDate.value = _anchorDay.subtract(Duration(days: _spanDays));
    await _loadRange();
  }

  Future<void> stepForward() async {
    if (!canGoForward) return;
    var next = _anchorDay.add(Duration(days: _spanDays));
    if (next.isAfter(_today)) next = _today;
    anchorDate.value = next;
    await _loadRange();
  }

  /// Jump directly to any date via the picker instead of stepping one window
  /// at a time — the fast way to reach the day a parent is asking about.
  Future<void> pickDate(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _anchorDay,
      minimumDate: DateTime(_today.year - 3),
      maximumDate: _today,
      showTodayButton: true,
    );
    if (picked == null) return;
    anchorDate.value = DateTime(picked.year, picked.month, picked.day);
    await _loadRange();
  }

  // ─── Loaders ────────────────────────────────────────────────────────────────

  Future<void> _loadRange() async {
    isRangeLoading.value = true;
    await Future.wait([
      _loadAttendanceRange(),
      _loadActivities(),
      _loadHomework(),
      _loadNotes(),
    ]);
    isRangeLoading.value = false;
  }

  Future<void> _loadChild() => _childSvc.getAll(callBack: (list) {
    child.value = list.whereType<ChildModel>()
        .where((c) => c.key == childId).firstOrNull;
  });

  Future<void> _loadParent() async {
    final pids = <String>[];
    await _linkSvc.getAll(callBack: (list) {
      final links = list.whereType<ParentChildModel>()
          .where((l) => l.childId == childId).toList()
        ..sort((a, b) => (b.isPrimary ? 1 : 0).compareTo(a.isPrimary ? 1 : 0));
      for (final l in links) {
        if (l.parentId.isNotEmpty && !pids.contains(l.parentId)) {
          pids.add(l.parentId);
        }
      }
    });
    final legacy = child.value?.parentId;
    if (pids.isEmpty && legacy != null && legacy.isNotEmpty) pids.add(legacy);
    if (pids.isEmpty) { parents.clear(); return; }
    await _parentSvc.getAll(callBack: (list) {
      final all = list.whereType<ParentModel>().toList();
      parents.value = pids
          .map((id) => all.where((p) => p.uid == id).firstOrNull)
          .whereType<ParentModel>()
          .toList();
    });
  }

  Future<void> _loadEnrollmentAndClass() async {
    await _enrollSvc.getAll(callBack: (list) {
      final enrs = list.whereType<EnrollmentModel>()
          .where((e) => e.childId == childId).toList()
        ..sort((a, b) => (b.enrollmentDate ?? 0).compareTo(a.enrollmentDate ?? 0));
      enrollment.value = enrs.firstOrNull;
    });
    final cid = enrollment.value?.classroomId ?? child.value?.classroomId;
    if (cid == null || cid.isEmpty) return;
    await _classroomSvc.getAll(callBack: (list) {
      classroom.value = list.whereType<ClassroomModel>()
          .where((c) => c.key == cid).firstOrNull;
    });
  }

  Future<void> _loadAttendanceRange() {
    final startStr = _dateStr(_windowStart);
    final endStr = _dateStr(_anchorDay);
    return _attendSvc.getAll(callBack: (list) {
      recentAttendance.value = list.whereType<ChildAttendanceModel>()
          .where((a) =>
              a.childId == childId &&
              a.date.compareTo(startStr) >= 0 &&
              a.date.compareTo(endStr) <= 0)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _loadActivities() async {
    if (_nurseryId.isEmpty || _classroomId.isEmpty) {
      activities.clear();
      return;
    }
    final list = await _activitySvc.getCompletedForDateRange(
      _nurseryId,
      _classroomId,
      startMs: _startMs,
      endMs: _endMs,
    );
    activities.value = list
        .where((a) => a.childIds.contains(childId))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<void> _loadHomework() async {
    if (_nurseryId.isEmpty || _classroomId.isEmpty) {
      homework.clear();
      return;
    }
    homework.value = await _activitySvc.getHomeworkByClassroom(
      nurseryId: _nurseryId,
      classroomId: _classroomId,
    );
  }

  Future<void> _loadNotes() async {
    if (_nurseryId.isEmpty) {
      teacherNotes.clear();
      return;
    }
    teacherNotes.value = await _eduSvc.getNotesForRange(
      _nurseryId,
      childId,
      startMs: _startMs,
      endMs: _endMs,
    );
  }

  Future<void> addParent() async {
    await Get.toNamed(parentAccountView,
        arguments: {'childId': childId, 'childName': childName});
    loadProfile();
  }

  void goToAttendance() => Get.toNamed(checkInView);

  // ─── Withdrawal ─────────────────────────────────────────────────────────────

  /// Only enrollment-managing roles may withdraw a child. Teachers, nannies and
  /// parents reach this screen read-only.
  bool get canWithdraw {
    final r = _session.effectiveRole;
    return r == UserType.receptionist ||
        r == UserType.owner ||
        r == UserType.branchManager ||
        r == UserType.superAdmin;
  }

  bool get isWithdrawn => child.value?.isWithdrawn ?? false;

  /// Only enrollment-managing staff may change a child's shift — the same set
  /// allowed to withdraw. Parents and teachers reach the profile read-only.
  bool get canEditShift => canWithdraw;

  /// Persists a new shift for the child (staff only) and reloads the profile so
  /// the value shows immediately. No-ops when the shift is unchanged.
  Future<void> updateShift(String shift) async {
    final current = child.value;
    if (current == null || current.key == null) return;
    if (current.shift == shift) {
      Get.back();
      return;
    }
    Loader.show();
    await _childSvc.update(
      item: current.copyWith(shift: shift),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Get.back();
          loadProfile();
          Loader.showSuccess('child_details_saved'.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  /// Permanently withdraws the child. The server-side `withdrawChild` Cloud
  /// Function hard-deletes the child record + all child-scoped data, logs the
  /// withdrawal (so the manager's monthly-movement stat survives), and deletes
  /// any parent left with no other children — including their Firebase Auth
  /// account, so they can re-register elsewhere later. On success we pop back
  /// to the list, which reloads and drops the now-deleted child.
  Future<void> withdraw({required String reason}) async {
    final current = child.value;
    if (current == null || current.key == null) return;
    Loader.show();
    final ok = await _withdrawalSvc.withdrawChild(
      childId: current.key!,
      reason: reason,
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('child_withdraw_success'.tr);
      Get.back();
    } else {
      Loader.showError('child_withdraw_error'.tr);
    }
  }

  // ─── Date helpers ─────────────────────────────────────────────────────────

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  static String _arMonth(DateTime d) => _arMonths[d.month - 1];
  static String _dayLabel(DateTime d) => '${d.day} ${_arMonth(d)}';
}
