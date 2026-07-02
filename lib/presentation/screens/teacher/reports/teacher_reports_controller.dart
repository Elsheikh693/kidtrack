import '../../../../index/index_main.dart';

class TeacherReportsController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _service;

  final isLoading = true.obs;
  final classrooms = <ClassroomModel>[].obs;
  final selectedClassroomId = 'all'.obs;
  // classroomId → completed activities for today
  final _activitiesMap = <String, List<ClassroomActivityModel>>{};
  // classroomId → children
  final _childrenMap = <String, List<ChildModel>>{};
  final _refreshTrigger = 0.obs;

  String get nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = Get.find<TeacherActivityService>();
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
    for (final c in classrooms) {
      await _loadForClassroom(c.key ?? '');
    }
    _refreshTrigger.value++;
    isLoading.value = false;
  }

  Future<void> _loadForClassroom(String classroomId) async {
    if (classroomId.isEmpty) return;
    final results = await Future.wait([
      _service.getTodayCompleted(nurseryId, classroomId),
      _service.loadChildren(nurseryId, classroomId),
    ]);
    _activitiesMap[classroomId] = results[0] as List<ClassroomActivityModel>;
    _childrenMap[classroomId] = results[1] as List<ChildModel>;
  }

  void selectClassroom(String id) => selectedClassroomId.value = id;

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

  double get averageRating {
    int total = 0;
    int excellent = 0;
    for (final a in displayedActivities) {
      total += a.evaluations.length;
      excellent +=
          a.evaluations.values.where((v) => v == 'excellent').length;
    }
    if (total == 0) return 0.0;
    return (excellent / total) * 5.0;
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
      list.add('✓ $rate% من الطلاب تم تقييمهم اليوم');
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
      list.add('✓ مادة ${best.key} الأكثر نشاطاً اليوم');
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
        list.add('⚠ ${child.firstName} يحتاج متابعة في ${entry.value} أنشطة');
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
          list.add('⭐ ${child.firstName} حقق تقييماً ممتازاً في ${topEntry.value} أنشطة');
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
