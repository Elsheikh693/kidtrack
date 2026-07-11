import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/child_current_status/child_current_status_model.dart';
import '../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../../Data/models/child_attendance/child_attendance_model.dart';
import '../Utils/logger.dart';

// Central service for all child status changes.
// Teacher NEVER calls this — teacher writes to classroomActivities only.
// Every method atomically:
//   1. updates childCurrentStatus/{childId}
//   2. appends one record to childDailyEvents/{date}/{childId}/{newId}
class ChildStatusService {
  static const _tag = 'CHILD_STATUS';

  final _db = FirebaseDatabase.instance;

  // ── Firebase references ────────────────────────────────────────────────────

  DatabaseReference _statusRef(String nurseryId, String childId) =>
      _db.ref('platform/$nurseryId/childCurrentStatus/$childId');

  DatabaseReference _eventsRef(String nurseryId, String date, String childId) =>
      _db.ref('platform/$nurseryId/childDailyEvents/$date/$childId');

  DatabaseReference _attendanceRef(String nurseryId) =>
      _db.ref('platform/$nurseryId/childAttendance');

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _today() => _dateKey(DateTime.now());

  // ── Streams ────────────────────────────────────────────────────────────────

  Stream<ChildCurrentStatusModel?> watchStatus(
      String nurseryId, String childId) {
    return _statusRef(nurseryId, childId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return ChildCurrentStatusModel.fromJson(
        Map<String, dynamic>.from(data as Map),
        childId: childId,
      );
    });
  }

  Stream<List<ChildDailyEventModel>> watchTodayEvents(
          String nurseryId, String childId) =>
      watchEventsForDay(nurseryId, childId, DateTime.now());

  /// Events for an arbitrary day — powers the parent home "view a past day".
  Stream<List<ChildDailyEventModel>> watchEventsForDay(
      String nurseryId, String childId, DateTime day) {
    final date = _dateKey(day);
    final controller =
        StreamController<List<ChildDailyEventModel>>.broadcast();

    _eventsRef(nurseryId, date, childId).onValue.listen(
      (event) {
        try {
          final data = event.snapshot.value;
          if (data == null) {
            controller.add([]);
            return;
          }
          final map = Map<String, dynamic>.from(data as Map);
          final list = map.entries
              .map((e) => ChildDailyEventModel.fromJson(
                    Map<String, dynamic>.from(e.value as Map),
                    id: e.key,
                  ))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          controller.add(list);
        } catch (e) {
          AppLogger.error(_tag, 'watchEventsForDay: $e');
          controller.add([]);
        }
      },
      onError: (e) {
        AppLogger.error(_tag, 'watchEventsForDay stream error: $e');
        controller.add([]);
      },
    );
    return controller.stream;
  }

  /// The single source of truth for "present today" used across every screen
  /// (teacher home card, classroom-states sheet, reception dashboard) so the
  /// counts can never drift. Emits the live set of child IDs that have a dated
  /// attendance record for [day] (defaults to today) with status present/late.
  ///
  /// Because this is date-scoped, a child checked in on a previous day and
  /// never checked out is NOT reported today — the dated record acts as an
  /// implicit daily reset, unlike the childCurrentStatus cache.
  Stream<Set<String>> watchPresentIdsForDay(String nurseryId, [DateTime? day]) {
    final date = _dateKey(day ?? DateTime.now());
    final controller = StreamController<Set<String>>.broadcast();

    final sub = _attendanceRef(nurseryId)
        .orderByChild('date')
        .equalTo(date)
        .onValue
        .listen(
      (event) {
        final ids = <String>{};
        final data = event.snapshot.value;
        if (data is Map) {
          for (final v in data.values) {
            if (v is! Map) continue;
            final status = v['status']?.toString();
            if (status != 'present' && status != 'late') continue;
            final childId = v['childId']?.toString();
            if (childId != null && childId.isNotEmpty) ids.add(childId);
          }
        }
        controller.add(ids);
      },
      onError: (e) {
        AppLogger.error(_tag, 'watchPresentIdsForDay: $e');
        controller.add(<String>{});
      },
    );
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  // ── Internal write helper ──────────────────────────────────────────────────

  Future<bool> _write({
    required String nurseryId,
    required String childId,
    required Map<String, dynamic> statusData,
    required ChildDailyEventModel event,
  }) async {
    try {
      final date = _today();
      final eventRef = _eventsRef(nurseryId, date, childId).push();
      final eventWithId = event.toJson();

      await _db.ref().update({
        'platform/$nurseryId/childCurrentStatus/$childId': statusData,
        'platform/$nurseryId/childDailyEvents/$date/$childId/${eventRef.key}':
            eventWithId,
      });
      return true;
    } catch (e) {
      AppLogger.error(_tag, '_write: $e');
      return false;
    }
  }

  // ── Attendance record helpers ──────────────────────────────────────────────

  // Deterministic key — one record per child per day, easily updatable.
  String _attendanceKey(String date, String childId) =>
      '${date}_$childId';

  // ── Reception ─────────────────────────────────────────────────────────────

  Future<bool> checkInChild({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String receptionistId,
    String? classroomId,
  }) async {
    final now = DateTime.now();
    final date = _today();

    final currentStatus = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.checkedIn,
      updatedAt: now,
      updatedById: receptionistId,
      updatedByRole: ChildEventSource.reception,
      checkInTime: now,
    );

    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.checkIn,
      source: ChildEventSource.reception,
      title: 'وصل الحضانة',
      createdBy: receptionistId,
      createdByRole: ChildEventSource.reception,
      createdAt: now.millisecondsSinceEpoch,
    );

    // Attendance history record — set on check-in, checkOutTime added later.
    final attendance = ChildAttendanceModel(
      nurseryId: nurseryId,
      childId: childId,
      branchId: branchId,
      classroomId: classroomId,
      date: date,
      status: 'present',
      checkInTime: now.millisecondsSinceEpoch,
      checkInBy: receptionistId,
      createdAt: now.millisecondsSinceEpoch,
    );

    try {
      final eventRef = _eventsRef(nurseryId, date, childId).push();
      await _db.ref().update({
        'platform/$nurseryId/childCurrentStatus/$childId': currentStatus.toJson(),
        'platform/$nurseryId/childDailyEvents/$date/$childId/${eventRef.key}': event.toJson(),
        'platform/$nurseryId/childAttendance/${_attendanceKey(date, childId)}': attendance.toJson(),
      });
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'checkInChild: $e');
      return false;
    }
  }

  Future<bool> checkOutChild({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String receptionistId,
    required ChildCurrentStatusModel current,
  }) async {
    final now = DateTime.now();
    final date = _today();

    final newStatus = current.copyWith(
      status: ChildStatus.checkedOut,
      pickupRequested: false,
      statusStartedAt: now,
      updatedAt: now,
      updatedById: receptionistId,
      updatedByRole: ChildEventSource.reception,
      checkOutTime: now,
    );

    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.checkOut,
      source: ChildEventSource.reception,
      title: 'غادر الحضانة',
      createdBy: receptionistId,
      createdByRole: ChildEventSource.reception,
      createdAt: now.millisecondsSinceEpoch,
    );

    try {
      final eventRef = _eventsRef(nurseryId, date, childId).push();
      await _db.ref().update({
        'platform/$nurseryId/childCurrentStatus/$childId': newStatus.toJson(),
        'platform/$nurseryId/childDailyEvents/$date/$childId/${eventRef.key}': event.toJson(),
        // Patch only the checkout fields — preserves checkInTime written earlier.
        'platform/$nurseryId/childAttendance/${_attendanceKey(date, childId)}/checkOutTime':
            now.millisecondsSinceEpoch,
        'platform/$nurseryId/childAttendance/${_attendanceKey(date, childId)}/checkOutBy':
            receptionistId,
        'platform/$nurseryId/childAttendance/${_attendanceKey(date, childId)}/updatedAt':
            now.millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'checkOutChild: $e');
      return false;
    }
  }

  Future<bool> checkOutChildByPickup({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String staffId,
  }) async {
    try {
      final snap = await _statusRef(nurseryId, childId).get();
      if (!snap.exists || snap.value == null) return false;
      final current = ChildCurrentStatusModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
        childId: childId,
      );
      return checkOutChild(
        nurseryId: nurseryId,
        branchId: branchId,
        childId: childId,
        receptionistId: staffId,
        current: current,
      );
    } catch (_) {
      return false;
    }
  }

  // ── Nanny — meals ─────────────────────────────────────────────────────────

  Future<bool> startMeal({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String nannyId,
    required String mealType, // breakfast | lunch | snack
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.havingMeal,
      statusStartedAt: now,
      updatedAt: now,
      updatedById: nannyId,
      updatedByRole: ChildEventSource.nanny,
    );
    final label = _mealLabel(mealType);
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.mealStarted,
      source: ChildEventSource.nanny,
      title: label,
      mealType: mealType,
      createdBy: nannyId,
      createdByRole: ChildEventSource.nanny,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  Future<bool> finishMeal({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String nannyId,
    required String mealType,
    required String mealStatus, // ate_all | ate_half | refused
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.checkedIn,
      updatedAt: now,
      updatedById: nannyId,
      updatedByRole: ChildEventSource.nanny,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.mealCompleted,
      source: ChildEventSource.nanny,
      title: '${_mealLabel(mealType)} — ${_mealStatusLabel(mealStatus)}',
      mealType: mealType,
      mealStatus: mealStatus,
      createdBy: nannyId,
      createdByRole: ChildEventSource.nanny,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  // ── Nanny — nap ───────────────────────────────────────────────────────────

  Future<bool> startNap({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String nannyId,
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.sleeping,
      statusStartedAt: now,
      updatedAt: now,
      updatedById: nannyId,
      updatedByRole: ChildEventSource.nanny,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.napStarted,
      source: ChildEventSource.nanny,
      title: 'بدأ القيلولة',
      createdBy: nannyId,
      createdByRole: ChildEventSource.nanny,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  Future<bool> finishNap({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String nannyId,
    String? sessionId,
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.checkedIn,
      updatedAt: now,
      updatedById: nannyId,
      updatedByRole: ChildEventSource.nanny,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.napCompleted,
      source: ChildEventSource.nanny,
      title: 'استيقظ من القيلولة',
      sessionId: sessionId,
      createdBy: nannyId,
      createdByRole: ChildEventSource.nanny,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  // ── Bus chaperone ─────────────────────────────────────────────────────────

  Future<bool> boardBus({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String chaperoneId,
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.onBus,
      statusStartedAt: now,
      updatedAt: now,
      updatedById: chaperoneId,
      updatedByRole: ChildEventSource.bus,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.busBoarded,
      source: ChildEventSource.bus,
      title: 'ركب الباص',
      createdBy: chaperoneId,
      createdByRole: ChildEventSource.bus,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  Future<bool> arriveBus({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String chaperoneId,
  }) async {
    final now = DateTime.now();
    final status = ChildCurrentStatusModel(
      childId: childId,
      status: ChildStatus.checkedIn,
      updatedAt: now,
      updatedById: chaperoneId,
      updatedByRole: ChildEventSource.bus,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.busArrived,
      source: ChildEventSource.bus,
      title: 'وصل من الباص',
      createdBy: chaperoneId,
      createdByRole: ChildEventSource.bus,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  // ── Parent ────────────────────────────────────────────────────────────────

  // Marks pickupRequested=true without changing the base status.
  // The parent is on their way — child is still inside/sleeping/etc.
  Future<bool> requestPickup({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String parentId,
    required ChildCurrentStatusModel current,
  }) async {
    final now = DateTime.now();
    final status = current.copyWith(
      pickupRequested: true,
      updatedAt: now,
      updatedById: parentId,
      updatedByRole: ChildEventSource.parent,
    );
    final event = ChildDailyEventModel(
      id: '',
      childId: childId,
      nurseryId: nurseryId,
      branchId: branchId,
      eventType: ChildEventType.pickupRequested,
      source: ChildEventSource.parent,
      title: 'ولي الأمر في الطريق',
      createdBy: parentId,
      createdByRole: ChildEventSource.parent,
      createdAt: now.millisecondsSinceEpoch,
    );
    return _write(
      nurseryId: nurseryId,
      childId: childId,
      statusData: status.toJson(),
      event: event,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _mealLabel(String type) {
    switch (type) {
      case 'breakfast': return 'وجبة الإفطار';
      case 'lunch':     return 'وجبة الغداء';
      case 'snack':     return 'وجبة الوجبة الخفيفة';
      default:          return 'وجبة';
    }
  }

  static String _mealStatusLabel(String s) {
    switch (s) {
      case 'ate_all':  return 'أكل كل شيء';
      case 'ate_half': return 'أكل النصف';
      case 'refused':  return 'رفض الأكل';
      default:         return s;
    }
  }
}
