import '../../../../index/index_main.dart';

class HomeworkTabController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _service;

  final isLoading = true.obs;
  final classrooms = <ClassroomModel>[].obs;
  final selectedClassroomId = 'all'.obs;
  final selectedSubjectName = 'all'.obs;
  final selectedDateFilter = 2.obs; // 0=week, 1=month, 2=all

  // homeworkId → statuses
  final _statusesMap = <String, Map<String, HomeworkStatus>>{};
  // homeworkId → childIds whose parent confirmed at home
  final _submissionsMap = <String, Set<String>>{};
  // classroomId → children
  final _childrenMap = <String, List<ChildModel>>{};
  // flat list of all loaded homework
  final _homeworkList = <HomeworkModel>[];
  final _refreshTrigger = 0.obs;

  String get nurseryId => _session.nurseryId ?? '';
  String get uid => _session.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = Get.find<TeacherActivityService>();
    _load();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading.value = true;
    _homeworkList.clear();
    _statusesMap.clear();
    _submissionsMap.clear();
    _childrenMap.clear();

    if (uid.isEmpty || nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }

    classrooms.value = await _service.resolveClassrooms(nurseryId, uid);

    // Fetch children + homework per classroom
    await Future.wait(classrooms.map((c) => _loadClassroom(c.key ?? '')));

    // Fetch statuses + parent submissions for every homework
    final uniqueIds = _homeworkList.map((hw) => hw.key ?? '').where((k) => k.isNotEmpty).toSet();
    await Future.wait(uniqueIds.map(_loadHomeworkState));

    _refreshTrigger.value++;
    isLoading.value = false;
  }

  Future<void> _loadClassroom(String classroomId) async {
    if (classroomId.isEmpty) return;
    final results = await Future.wait([
      _service.loadChildren(nurseryId, classroomId),
      _service.getHomeworkByClassroom(nurseryId: nurseryId, classroomId: classroomId),
    ]);
    _childrenMap[classroomId] = results[0] as List<ChildModel>;
    _homeworkList.addAll(results[1] as List<HomeworkModel>);
  }

  Future<void> _loadHomeworkState(String hwId) async {
    final results = await Future.wait([
      _service.getHomeworkStatuses(nurseryId: nurseryId, homeworkId: hwId),
      _service.getHomeworkSubmissions(nurseryId: nurseryId, homeworkId: hwId),
    ]);
    _statusesMap[hwId] = results[0] as Map<String, HomeworkStatus>;
    _submissionsMap[hwId] = results[1] as Set<String>;
  }

  // ── Filters ───────────────────────────────────────────────────────────────

  void selectClassroom(String id) {
    selectedClassroomId.value = id;
    selectedSubjectName.value = 'all';
  }

  void selectSubject(String name) => selectedSubjectName.value = name;

  void selectDateFilter(int idx) {
    selectedDateFilter.value = idx;
    _refreshTrigger.value++;
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  Set<String> get availableSubjectNames {
    final result = <String>{};
    for (final hw in _homeworkList) {
      if (hw.subjectName != null && hw.subjectName!.isNotEmpty) {
        result.add(hw.subjectName!);
      }
    }
    return result;
  }

  List<HomeworkModel> get displayedHomework {
    _refreshTrigger.value;
    var list = List<HomeworkModel>.from(_homeworkList);

    final cId = selectedClassroomId.value;
    if (cId != 'all') list = list.where((hw) => hw.classroomId == cId).toList();

    final sName = selectedSubjectName.value;
    if (sName != 'all') list = list.where((hw) => hw.subjectName == sName).toList();

    final from = _fromMs();
    if (from != null) list = list.where((hw) => (hw.createdAt ?? 0) >= from).toList();

    list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return list;
  }

  int? _fromMs() {
    final now = DateTime.now();
    switch (selectedDateFilter.value) {
      case 0:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day)
            .millisecondsSinceEpoch;
      case 1:
        return DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
      default:
        return null;
    }
  }

  Map<String, HomeworkStatus> statusesFor(String hwId) =>
      _statusesMap[hwId] ?? {};

  List<ChildModel> childrenFor(HomeworkModel hw) =>
      _childrenMap[hw.classroomId] ?? [];

  int totalChildren(HomeworkModel hw) => (_childrenMap[hw.classroomId] ?? []).length;

  int countStatus(String hwId, HomeworkStatus s) =>
      (_statusesMap[hwId] ?? {}).values.where((v) => v == s).length;

  int unmarkedCount(HomeworkModel hw) {
    final hwId = hw.key ?? '';
    final total = totalChildren(hw);
    final marked = (_statusesMap[hwId] ?? {}).length;
    return total - marked;
  }

  // completion % = (completed + partial*0.5) / total * 100
  double completionRate(HomeworkModel hw) {
    final total = totalChildren(hw);
    if (total == 0) return 0;
    final hwId = hw.key ?? '';
    final done = countStatus(hwId, HomeworkStatus.completed);
    final partial = countStatus(hwId, HomeworkStatus.partiallyCompleted);
    return (done + partial * 0.5) / total;
  }

  // ── Independent state counts (per homework) ─────────────────────────────────
  // Assigned : children the homework went out to (whole classroom)
  // Submitted: parents who confirmed it was done at home
  // Awaiting : assigned minus submitted (parent hasn't confirmed yet)
  // Reviewed : children the teacher has marked an assessment for

  int submittedCount(HomeworkModel hw) =>
      (_submissionsMap[hw.key ?? ''] ?? const <String>{}).length;

  int awaitingCount(HomeworkModel hw) =>
      (totalChildren(hw) - submittedCount(hw)).clamp(0, 1 << 30);

  int reviewedCount(HomeworkModel hw) =>
      (_statusesMap[hw.key ?? ''] ?? const {}).length;

  int get refreshToken => _refreshTrigger.value;

  int get overallTotal => displayedHomework.length;

  int get overallAssigned =>
      displayedHomework.fold(0, (acc, hw) => acc + totalChildren(hw));
  int get overallSubmitted =>
      displayedHomework.fold(0, (acc, hw) => acc + submittedCount(hw));
  int get overallAwaiting =>
      displayedHomework.fold(0, (acc, hw) => acc + awaitingCount(hw));
  int get overallReviewed =>
      displayedHomework.fold(0, (acc, hw) => acc + reviewedCount(hw));
  double get overallCompletionRate {
    final list = displayedHomework;
    if (list.isEmpty) return 0;
    final sum = list.fold<double>(0, (acc, hw) => acc + completionRate(hw));
    return sum / list.length;
  }

  // Saves updated statuses for one homework (from detail view)
  Future<void> saveStatuses({
    required HomeworkModel homework,
    required Map<String, HomeworkStatus> statuses,
  }) async {
    final hwId = homework.key ?? '';
    if (hwId.isEmpty) return;
    await _service.saveAllHomeworkStatuses(
      nurseryId: nurseryId,
      homeworkId: hwId,
      classroomId: homework.classroomId,
      statuses: statuses,
      teacherId: uid,
    );
    _statusesMap[hwId] = Map.from(statuses);
    _refreshTrigger.value++;
  }

  Future<void> reload() => _load();
}
