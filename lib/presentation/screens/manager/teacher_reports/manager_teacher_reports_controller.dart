import '../../../../index/index_main.dart';
import 'models/teacher_report_models.dart';

/// Aggregates completed classroom activities across the branch into per-teacher
/// performance for the Branch Manager. Read-only: it never writes activity data,
/// it just reshapes what teachers already produced into reports + charts.
class ManagerTeacherReportsController extends GetxController {
  final isLoading = true.obs;
  final selectedRange = TrRange.day.obs;

  /// The day the report ends on (and, in `day` mode, the single day shown).
  final anchorDate = DateTime.now().obs;

  final teachers = <TeacherPerformance>[].obs;
  final summary = Rxn<TrSummary>();

  final _session = SessionService();
  final _activitySvc = TeacherActivityService();
  late final ClassroomParentService _classroomSvc;
  late final StaffParentService _staffSvc;

  // Resolved branch reference data.
  final _classroomNames = <String, String>{};
  final _teacherNames = <String, String>{};
  final _teacherPhotos = <String, String?>{};

  String get nurseryId => _session.nurseryId ?? '';
  String get branchId => _session.branchId ?? '';

  @override
  void onInit() {
    super.onInit();
    _classroomSvc = Get.find<ClassroomParentService>();
    _staffSvc = Get.find<StaffParentService>();
    loadData();
  }

  // ── Span helpers ───────────────────────────────────────────────────────────

  DateTime get _anchorDayStart {
    final a = anchorDate.value;
    return DateTime(a.year, a.month, a.day);
  }

  int get _spanStartMs {
    final start = _anchorDayStart
        .subtract(Duration(days: selectedRange.value.spanDays - 1));
    return start.millisecondsSinceEpoch;
  }

  int get _spanEndMs {
    final end = _anchorDayStart.add(const Duration(days: 1));
    return end.millisecondsSinceEpoch - 1;
  }

  bool get isToday {
    final n = DateTime.now();
    final a = anchorDate.value;
    return n.year == a.year && n.month == a.month && n.day == a.day;
  }

  /// True while in single-day mode — drives whether cards drill into a detailed
  /// day feedback timeline.
  bool get isDayMode => selectedRange.value == TrRange.day;

  // ── User actions ───────────────────────────────────────────────────────────

  void setRange(TrRange range) {
    if (range == selectedRange.value) return;
    selectedRange.value = range;
    _rebuild();
  }

  Future<void> pickDate() async {
    final picked = await showAppDatePicker(
      Get.context!,
      initialDate: anchorDate.value,
      maximumDate: DateTime.now(),
    );
    if (picked == null) return;
    anchorDate.value = picked;
    await loadData();
  }

  // ── Loading + aggregation ───────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadClassrooms(), _loadTeachers()]);
    await _rebuild();
    isLoading.value = false;
  }

  Future<void> _loadClassrooms() async {
    _classroomNames.clear();
    await _classroomSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ClassroomModel>()) {
        if ((c.isAllBranches || c.branchIds.contains(branchId)) && c.isActive && c.key != null) {
          _classroomNames[c.key!] = c.name;
        }
      }
    });
  }

  Future<void> _loadTeachers() async {
    _teacherNames.clear();
    _teacherPhotos.clear();
    await _staffSvc.getAll(callBack: (list) {
      for (final s in list.whereType<StaffModel>()) {
        if (s.branchId == branchId &&
            s.isActive &&
            s.template == StaffTemplate.teacher &&
            s.key != null) {
          _teacherNames[s.key!] = s.name;
          _teacherPhotos[s.key!] = s.profileImage;
        }
      }
    });
  }

  Future<void> _rebuild() async {
    final classroomIds = _classroomNames.keys.toList();
    final activities = await _activitySvc.getCompletedForClassrooms(
      nurseryId,
      classroomIds,
      startMs: _spanStartMs,
      endMs: _spanEndMs,
    );

    final spanDays = selectedRange.value.spanDays;
    final startDay = DateTime.fromMillisecondsSinceEpoch(_spanStartMs);
    final byTeacher = <String, List<ClassroomActivityModel>>{};
    for (final a in activities) {
      byTeacher.putIfAbsent(a.teacherId, () => []).add(a);
    }

    // Build a performance row for every known teacher (so idle teachers still
    // surface with zeroes) plus any activity author not in the staff list.
    final teacherIds = <String>{..._teacherNames.keys, ...byTeacher.keys};
    final rows = <TeacherPerformance>[];

    for (final id in teacherIds) {
      final acts = (byTeacher[id] ?? [])
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      var minutes = 0;
      var evals = 0;
      var photos = 0;
      final days = <String>{};
      final children = <String>{};
      final classNames = <String>{};
      final daily = List<int>.filled(spanDays, 0);

      for (final a in acts) {
        final end = a.endedAt ?? a.startedAt;
        final m = ((end - a.startedAt) / 60000).round();
        if (m > 0) minutes += m;
        evals += a.evaluations.length;
        photos += a.photos.length;
        children.addAll(a.childIds);

        final d = DateTime.fromMillisecondsSinceEpoch(a.startedAt);
        days.add('${d.year}-${d.month}-${d.day}');
        final name = _classroomNames[a.classroomId];
        if (name != null) classNames.add(name);

        final idx = DateTime(d.year, d.month, d.day).difference(startDay).inDays;
        if (idx >= 0 && idx < spanDays) daily[idx]++;
      }

      rows.add(TeacherPerformance(
        teacherId: id,
        name: _teacherNames[id] ?? 'tr_unknown_teacher'.tr,
        photo: _teacherPhotos[id],
        classroomNames: classNames.toList()..sort(),
        activities: acts,
        sessionCount: acts.length,
        workingMinutes: minutes,
        workingDays: days.length,
        evaluationCount: evals,
        photoCount: photos,
        childrenReached: children.length,
        dailyCounts: daily,
      ));
    }

    // Active teachers first, ranked by activity volume, then working time.
    rows.sort((a, b) {
      if (a.hasActivity != b.hasActivity) return a.hasActivity ? -1 : 1;
      final c = b.sessionCount.compareTo(a.sessionCount);
      if (c != 0) return c;
      return b.workingMinutes.compareTo(a.workingMinutes);
    });

    teachers.assignAll(rows);
    summary.value = TrSummary(
      activeTeachers: rows.where((r) => r.hasActivity).length,
      totalTeachers: _teacherNames.length,
      totalActivities: rows.fold(0, (a, r) => a + r.sessionCount),
      totalWorkingMinutes: rows.fold(0, (a, r) => a + r.workingMinutes),
      totalEvaluations: rows.fold(0, (a, r) => a + r.evaluationCount),
      totalPhotos: rows.fold(0, (a, r) => a + r.photoCount),
    );
  }
}
