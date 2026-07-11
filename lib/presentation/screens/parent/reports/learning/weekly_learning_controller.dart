import '../../../../../index/index_main.dart';

/// Topics covered in one subject during the week.
class LearningSubjectGroup {
  final String subjectName;
  final List<String> topics;
  const LearningSubjectGroup({required this.subjectName, required this.topics});
}

class WeeklyLearningController extends GetxController {
  late final TopicProgressParentService _progressSvc;
  late final AcademicTopicParentService _topicSvc;
  late final SubjectParentService _subjectSvc;
  late final ChildParentService _childSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;

  final isLoading = true.obs;
  final weekOffset = 0.obs;

  final groups = <LearningSubjectGroup>[].obs;
  final topicsCount = 0.obs;
  final subjectsCount = 0.obs;
  final isEmptyWeek = false.obs;

  String childName = '';
  String _classroomId = '';
  final _topicTitle = <String, String>{}; // topicId → title
  final _topicSubject = <String, String>{}; // topicId → subjectId
  final _subjectName = <String, String>{}; // subjectId → name
  final _progress = <TopicProgressModel>[];

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => weekOffset.value < 0;

  @override
  void onInit() {
    super.onInit();
    _progressSvc = Get.find<TopicProgressParentService>();
    _topicSvc = Get.find<AcademicTopicParentService>();
    _subjectSvc = Get.find<SubjectParentService>();
    _childSvc = Get.find<ChildParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    await _loadNursery();
    await _loadClassroom(_activeChild.childId.value);
    await _loadCatalog();
    await _loadProgress();
    _recompute();
    isLoading.value = false;
  }

  Future<void> _loadNursery() async {
    final sessionNurseryId = SessionService().nurseryId ?? '';
    await _nurserySvc.getAll(
      callBack: (list) {
        final nurseries = list.whereType<NurseryModel>();
        if (nurseries.isEmpty) return;
        final n = nurseries.firstWhere(
          (item) => item.key == sessionNurseryId,
          orElse: () => nurseries.first,
        );
        nurseryName = n.name;
        nurseryLogo = n.logo;
      },
    );
  }

  Future<void> _loadClassroom(String childId) async {
    await _childSvc.getAll(
      callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          if (c.key == childId) {
            _classroomId = c.classroomId ?? '';
            break;
          }
        }
      },
    );
  }

  Future<void> _loadCatalog() async {
    await _topicSvc.getAll(
      callBack: (list) {
        for (final t in list.whereType<AcademicTopicModel>()) {
          if (t.key == null) continue;
          _topicTitle[t.key!] = t.title;
          _topicSubject[t.key!] = t.subjectId;
        }
      },
    );
    await _subjectSvc.getAll(
      callBack: (list) {
        for (final s in list.whereType<SubjectModel>()) {
          if (s.key != null) _subjectName[s.key!] = s.name;
        }
      },
    );
  }

  Future<void> _loadProgress() async {
    _progress.clear();
    await _progressSvc.getAll(
      callBack: (list) {
        _progress.addAll(list.whereType<TopicProgressModel>().where(
              (p) => p.classroomId == _classroomId && p.isDone,
            ));
      },
    );
  }

  void previousWeek() {
    weekOffset.value -= 1;
    _recompute();
  }

  void nextWeek() {
    if (!canGoNext) return;
    weekOffset.value += 1;
    _recompute();
  }

  DateTime _weekStart(int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceSat = (today.weekday - DateTime.saturday + 7) % 7;
    return today.subtract(Duration(days: daysSinceSat - offset * 7));
  }

  void _recompute() {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 7));
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    // subjectId → topic titles completed this week
    final bySubject = <String, List<String>>{};
    var total = 0;
    for (final p in _progress) {
      final done = p.completedAt;
      if (done == null || done < startMs || done >= endMs) continue;
      final topicId = p.topicId;
      final title = _topicTitle[topicId];
      if (title == null) continue;
      final subjectId = _topicSubject[topicId] ?? p.subjectId;
      bySubject.putIfAbsent(subjectId, () => []).add(title);
      total++;
    }

    final built = bySubject.entries
        .map((e) => LearningSubjectGroup(
              subjectName: _subjectName[e.key] ?? 'report_learning_other'.tr,
              topics: e.value,
            ))
        .toList()
      ..sort((a, b) => a.subjectName.compareTo(b.subjectName));

    groups.value = built;
    topicsCount.value = total;
    subjectsCount.value = built.length;
    isEmptyWeek.value = total == 0;
  }

  String get weekRangeLabel {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 6));
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
