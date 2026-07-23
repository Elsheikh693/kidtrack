import '../../../../index/index_main.dart';

class TeacherReportsController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _service;

  final isLoading = true.obs;
  final classrooms = <ClassroomModel>[].obs;
  final selectedClassroomId = 'all'.obs;
  // The day whose completed activities are shown. Defaults to today; the header
  // date navigator moves it back/forward (never into the future).
  final selectedDate = DateTime.now().obs;
  // classroomId → completed activities for the selected day
  final _activitiesMap = <String, List<ClassroomActivityModel>>{};
  // classroomId → children
  final _childrenMap = <String, List<ChildModel>>{};
  final _refreshTrigger = 0.obs;

  String get nurseryId => _session.nurseryId ?? '';

  /// True when the selected day is today — used to disable the "next day" arrow.
  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = Get.find<TeacherActivityService>();
    EvalLevelsRegistry.instance.ensureLoaded();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final uid = _session.userId ?? '';
    if (uid.isEmpty || nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }
    classrooms.value = await _service.resolveClassrooms(nurseryId, uid);
    await _loadActivities();
    isLoading.value = false;
  }

  /// Reloads only the completed activities for the current [selectedDate],
  /// keeping the already-resolved classroom list.
  Future<void> _loadActivities() async {
    for (final c in classrooms) {
      await _loadForClassroom(c.key ?? '');
    }
    _refreshTrigger.value++;
  }

  Future<void> _loadForClassroom(String classroomId) async {
    if (classroomId.isEmpty) return;
    final d = selectedDate.value;
    final dayStart = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    final dayEnd = dayStart + const Duration(days: 1).inMilliseconds - 1;
    final results = await Future.wait([
      _service.getCompletedForDateRange(
        nurseryId,
        classroomId,
        startMs: dayStart,
        endMs: dayEnd,
        teacherId: _session.userId,
      ),
      _service.loadChildren(nurseryId, classroomId),
    ]);
    final activities = results[0] as List<ClassroomActivityModel>
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _activitiesMap[classroomId] = activities;
    _childrenMap[classroomId] = results[1] as List<ChildModel>;
  }

  void selectClassroom(String id) => selectedClassroomId.value = id;

  /// Switches the shown day and reloads. Ignores requests for future days.
  Future<void> selectDate(DateTime date) async {
    final today = DateTime.now();
    final normalized = DateTime(date.year, date.month, date.day);
    final todayNorm = DateTime(today.year, today.month, today.day);
    if (normalized.isAfter(todayNorm)) return;
    selectedDate.value = normalized;
    isLoading.value = true;
    await _loadActivities();
    isLoading.value = false;
  }

  Future<void> goToPreviousDay() =>
      selectDate(selectedDate.value.subtract(const Duration(days: 1)));

  Future<void> goToNextDay() {
    if (isToday) return Future.value();
    return selectDate(selectedDate.value.add(const Duration(days: 1)));
  }

  List<ClassroomActivityModel> get displayedActivities {
    _refreshTrigger.value; // reactive dependency
    final id = selectedClassroomId.value;
    if (id == 'all') {
      final merged = _activitiesMap.values.expand((l) => l).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return merged;
    }
    return _activitiesMap[id] ?? [];
  }

  List<ChildModel> childrenForClassroom(String classroomId) =>
      _childrenMap[classroomId] ?? [];

  List<ChildModel> childrenForActivity(ClassroomActivityModel activity) =>
      _childrenMap[activity.classroomId] ?? [];

  // ── Computed stats ────────────────────────────────────────────────────────

  int get totalActivities => displayedActivities.length;

  int get totalEvaluations =>
      displayedActivities.fold(0, (s, a) => s + a.evaluations.length);

  int get participatingStudents {
    final ids = <String>{};
    for (final a in displayedActivities) {
      ids.addAll(a.childIds);
    }
    return ids.length;
  }

  /// Mean of the evaluated children's level scores (each level carries a 0-5
  /// score defined in settings), so the average reflects the dynamic levels.
  double get averageRating {
    final reg = EvalLevelsRegistry.instance;
    double sum = 0;
    int total = 0;
    for (final a in displayedActivities) {
      for (final v in a.evaluations.values) {
        sum += reg.scoreFor(v);
        total++;
      }
    }
    if (total == 0) return 0.0;
    return sum / total;
  }

  // ── Auto-generated insights ───────────────────────────────────────────────

  List<String> get insights {
    final list = <String>[];
    if (displayedActivities.isEmpty) return list;

    // Completion / evaluation rate
    int evalTotal = 0, childTotal = 0;
    for (final a in displayedActivities) {
      evalTotal += a.evaluations.length;
      childTotal += a.childIds.length;
    }
    if (childTotal > 0) {
      final rate = (evalTotal / childTotal * 100).round();
      list.add('teacherrep38_insight_eval_rate'.trParams({'rate': '$rate'}));
    }

    // Most active subject
    final subjectCounts = <String, int>{};
    for (final a in displayedActivities) {
      if (a.subjectName != null && a.subjectName!.isNotEmpty) {
        subjectCounts[a.subjectName!] =
            (subjectCounts[a.subjectName!] ?? 0) + 1;
      }
    }
    if (subjectCounts.isNotEmpty) {
      final best = subjectCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      list.add('teacherrep38_insight_top_subject'.trParams({'subject': best.key}));
    }

    // Students needing repeated attention
    final attentionCount = <String, int>{};
    for (final a in displayedActivities) {
      for (final e in a.evaluations.entries) {
        if (e.value == 'needs_attention') {
          attentionCount[e.key] = (attentionCount[e.key] ?? 0) + 1;
        }
      }
    }
    for (final entry in attentionCount.entries.where((e) => e.value >= 2).take(2)) {
      final child = _findChild(entry.key);
      if (child != null) {
        list.add('teacherrep38_insight_needs_attention'.trParams({
          'name': child.firstName,
          'count': '${entry.value}',
        }));
      }
    }

    // Top performer
    final excellentCount = <String, int>{};
    for (final a in displayedActivities) {
      for (final e in a.evaluations.entries) {
        if (e.value == 'excellent') {
          excellentCount[e.key] = (excellentCount[e.key] ?? 0) + 1;
        }
      }
    }
    if (excellentCount.isNotEmpty && displayedActivities.length >= 2) {
      final topEntry =
          excellentCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (topEntry.value >= 2) {
        final child = _findChild(topEntry.key);
        if (child != null) {
          list.add('teacherrep38_insight_excellent'.trParams({
            'name': child.firstName,
            'count': '${topEntry.value}',
          }));
        }
      }
    }

    return list;
  }

  ChildModel? _findChild(String childId) {
    for (final children in _childrenMap.values) {
      for (final c in children) {
        if (c.key == childId) return c;
      }
    }
    return null;
  }

  Future<void> reload() => _load();
}
