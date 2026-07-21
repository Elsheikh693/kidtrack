import '../../../../../../index/index_main.dart';
import '../../../../manager/teacher_reports/models/teacher_report_models.dart';

/// Teacher Performance report — the manager's per-teacher rollup, un-scoped to
/// the whole network (all branches). Over the last 30 days: activities, working
/// minutes, evaluations, photos and children reached per teacher, plus network
/// totals. Reuses the manager's [TeacherPerformance]/[TrSummary] view-models and
/// tr_* widgets so the two stay visually identical.
class OwnerTeacherPerfController extends GetxController {
  late final ClassroomParentService _classroomSvc;
  late final StaffParentService _staffSvc;
  late final TeacherActivityService _activitySvc;
  final SessionService _session = SessionService();

  final RxBool isLoading = false.obs;
  final RxList<TeacherPerformance> teachers = <TeacherPerformance>[].obs;
  final Rx<TrSummary> summary = TrSummary.empty.obs;

  static const int _spanDays = 30;

  final _classroomNames = <String, String>{};
  final _teacherNames = <String, String>{};
  final _teacherPhotos = <String, String?>{};

  @override
  void onInit() {
    super.onInit();
    _classroomSvc = Get.find<ClassroomParentService>();
    _staffSvc = Get.find<StaffParentService>();
    _activitySvc = Get.find<TeacherActivityService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadClassrooms(), _loadTeachers()]);
      await _rebuild();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadClassrooms() async {
    _classroomNames.clear();
    final list = await _fetch<ClassroomModel>(_classroomSvc.getAll);
    for (final c in list) {
      if (c.isActive && c.key != null) _classroomNames[c.key!] = c.name;
    }
  }

  Future<void> _loadTeachers() async {
    _teacherNames.clear();
    _teacherPhotos.clear();
    final list = await _fetch<StaffModel>(_staffSvc.getAll);
    for (final s in list) {
      if (s.isActive && s.template == StaffTemplate.teacher && s.key != null) {
        _teacherNames[s.key!] = s.name;
        _teacherPhotos[s.key!] = s.profileImage;
      }
    }
  }

  Future<void> _rebuild() async {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: _spanDays - 1));
    final startMs = startDay.millisecondsSinceEpoch;
    final endMs = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    final activities = await _activitySvc.getCompletedForClassrooms(
      _session.nurseryId ?? '',
      _classroomNames.keys.toList(),
      startMs: startMs,
      endMs: endMs,
    );

    final byTeacher = <String, List<ClassroomActivityModel>>{};
    for (final a in activities) {
      byTeacher.putIfAbsent(a.teacherId, () => []).add(a);
    }

    final teacherIds = <String>{..._teacherNames.keys, ...byTeacher.keys};
    final rows = <TeacherPerformance>[];
    for (final id in teacherIds) {
      rows.add(_row(id, byTeacher[id] ?? const [], startDay));
    }
    rows.sort((a, b) {
      if (a.hasActivity != b.hasActivity) return a.hasActivity ? -1 : 1;
      final c = b.sessionCount.compareTo(a.sessionCount);
      return c != 0 ? c : b.workingMinutes.compareTo(a.workingMinutes);
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

  TeacherPerformance _row(
      String id, List<ClassroomActivityModel> src, DateTime startDay) {
    final acts = [...src]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    var minutes = 0, evals = 0, photos = 0;
    final days = <String>{}, children = <String>{}, classNames = <String>{};
    final daily = List<int>.filled(_spanDays, 0);
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
      if (idx >= 0 && idx < _spanDays) daily[idx]++;
    }
    return TeacherPerformance(
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
    );
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
