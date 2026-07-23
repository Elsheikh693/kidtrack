import '../../../../../../index/index_main.dart';

/// Operational Punctuality — are timetabled sessions actually starting on time?
/// Matches completed activities (last 30 days) back to their `scheduleSlotId`
/// and compares the real start time against the slot's planned start. Only
/// timetable-linked sessions are measured; that matched count is shown for
/// transparency. Network-level.
class OwnerPunctualityController extends GetxController {
  late final ScheduleParentService _scheduleSvc;
  late final ClassroomParentService _classroomSvc;
  late final TeacherActivityService _activitySvc;
  final SessionService _session = SessionService();

  final RxBool isLoading = false.obs;

  static const int _spanDays = 30;
  static const int _graceMin = 10;

  /// slotId → planned start (minutes past midnight).
  final _slotStart = <String, int>{};
  int _scheduledSlots = 0;
  final _activities = <ClassroomActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _scheduleSvc = Get.find<ScheduleParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _activitySvc = Get.find<TeacherActivityService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final res = await Future.wait([
        _fetch<ScheduleModel>(_scheduleSvc.getAll),
        _fetch<ClassroomModel>(_classroomSvc.getAll),
      ]);
      final schedules = res[0].cast<ScheduleModel>();
      final classroomIds = res[1]
          .cast<ClassroomModel>()
          .where((c) => c.isActive && c.key != null)
          .map((c) => c.key!)
          .toList();

      _slotStart.clear();
      for (final s in schedules) {
        final m = _parseMinutes(s.startTime);
        if (s.key != null && m != null) _slotStart[s.key!] = m;
      }
      _scheduledSlots = schedules.length;

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: _spanDays - 1));
      final acts = await _activitySvc.getCompletedForClassrooms(
        _session.nurseryId ?? '',
        classroomIds,
        startMs: start.millisecondsSinceEpoch,
        endMs: DateTime(now.year, now.month, now.day, 23, 59, 59)
            .millisecondsSinceEpoch,
      );
      _activities.assignAll(acts);
    } finally {
      isLoading.value = false;
    }
  }

  int get scheduledSlots => _scheduledSlots;
  int get sessionsRun => _activities.length;

  /// Delay (minutes, ≥0) for each session linked to a known timetable slot.
  List<int> get _delays {
    final out = <int>[];
    for (final a in _activities) {
      final slot = a.scheduleSlotId;
      if (slot == null || !_slotStart.containsKey(slot)) continue;
      final started = DateTime.fromMillisecondsSinceEpoch(a.startedAt);
      final actualMin = started.hour * 60 + started.minute;
      final delay = actualMin - _slotStart[slot]!;
      out.add(delay < 0 ? 0 : delay);
    }
    return out;
  }

  int get matchedSessions => _delays.length;

  int get onTimeRate {
    final d = _delays;
    if (d.isEmpty) return 0;
    return ((d.where((x) => x <= _graceMin).length / d.length) * 100).round();
  }

  /// Average minutes late across matched sessions.
  int get avgDelay {
    final d = _delays;
    if (d.isEmpty) return 0;
    return (d.reduce((a, b) => a + b) / d.length).round();
  }

  bool get isEmpty => matchedSessions == 0;

  /// On-time / late / very-late distribution.
  List<DelayBucket> get distribution {
    final d = _delays;
    final total = d.length;
    final onTime = d.where((x) => x <= _graceMin).length;
    final late = d.where((x) => x > _graceMin && x <= 30).length;
    final veryLate = d.where((x) => x > 30).length;
    return [
      DelayBucket('owner_report_pu_ontime', onTime, total),
      DelayBucket('owner_report_pu_late', late, total),
      DelayBucket('owner_report_pu_very_late', veryLate, total),
    ];
  }

  int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  Future<List<T>> _fetch<T>(
      Future<void> Function({required Function(List<T?>) callBack}) getAll) {
    final c = Completer<List<T>>();
    getAll(callBack: (list) {
      if (!c.isCompleted) c.complete(list.whereType<T>().toList());
    });
    return c.future;
  }
}

/// One punctuality band.
class DelayBucket {
  final String labelKey;
  final int count;
  final int total;
  const DelayBucket(this.labelKey, this.count, this.total);
  double get share => total == 0 ? 0 : count / total;
}
