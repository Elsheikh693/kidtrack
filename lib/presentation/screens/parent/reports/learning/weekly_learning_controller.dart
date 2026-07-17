import '../../../../../index/index_main.dart';
import '../../../../../Global/services/parent_education_service.dart';

/// One lesson the child took part in — a completed classroom activity, with the
/// teacher's note when present.
class LearningTopicItem {
  final String title;
  final String? note; // teacher's note to the parent (per-child or group)
  const LearningTopicItem({required this.title, this.note});
}

/// Lessons taken in one subject during the week.
class LearningSubjectGroup {
  final String subjectName;
  final List<LearningTopicItem> topics;
  const LearningSubjectGroup({required this.subjectName, required this.topics});
}

class WeeklyLearningController extends GetxController {
  late final ChildParentService _childSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;
  final _eduSvc = ParentEducationService();

  final isLoading = true.obs;
  final weekOffset = 0.obs;

  final groups = <LearningSubjectGroup>[].obs;
  final topicsCount = 0.obs;
  final subjectsCount = 0.obs;
  final isEmptyWeek = false.obs;
  final insight = ''.obs;

  static const insightColor = Color(0xFF0891B2);

  // How far back we prefetch completed activities so week navigation stays fast.
  static const _historyWeeks = 12;

  String childName = '';
  String _childId = '';
  String _classroomId = '';
  final _activities = <ClassroomActivityModel>[];

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => weekOffset.value < 0;

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    _childId = _activeChild.childId.value;
    // Nursery details load alongside the classroom lookup; activities depend on
    // the resolved classroom id, so they follow.
    final nurseryF = _loadNursery();
    await _loadClassroom(_childId);
    await _loadActivities();
    await nurseryF;
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

  Future<void> _loadActivities() async {
    _activities.clear();
    if (_classroomId.isEmpty) return;
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    final start = _weekStart(-(_historyWeeks - 1));
    final end = _weekStart(0).add(const Duration(days: 7));
    final list = await _eduSvc.getActivitiesForRange(
      nurseryId,
      _classroomId,
      startMs: start.millisecondsSinceEpoch,
      endMs: end.millisecondsSinceEpoch,
    );
    _activities.addAll(list.where((a) => _childParticipated(a, _childId)));
  }

  bool _childParticipated(ClassroomActivityModel a, String childId) {
    if (a.childIds.isEmpty) return true;
    return a.childIds.contains(childId) ||
        a.evaluations.containsKey(childId) ||
        a.notes.containsKey(childId);
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

    // subjectName → lessons taken this week
    final bySubject = <String, List<LearningTopicItem>>{};
    var total = 0;
    for (final a in _activities) {
      final when = a.startedAt;
      if (when < startMs || when >= endMs) continue;
      final subject = (a.subjectName?.trim().isNotEmpty ?? false)
          ? a.subjectName!.trim()
          : 'report_learning_other'.tr;
      final note = a.notes[_childId] ?? a.groupNote;
      bySubject.putIfAbsent(subject, () => []).add(LearningTopicItem(
            title: a.title,
            note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
          ));
      total++;
    }

    final built = bySubject.entries
        .map((e) => LearningSubjectGroup(subjectName: e.key, topics: e.value))
        .toList()
      ..sort((a, b) => a.subjectName.compareTo(b.subjectName));

    groups.value = built;
    topicsCount.value = total;
    subjectsCount.value = built.length;
    isEmptyWeek.value = total == 0;
    _buildInsight(total, built.length);
  }

  void _buildInsight(int topics, int subjects) {
    if (topics == 0) {
      insight.value = '';
      return;
    }
    insight.value = 'report_learning_insight'.trParams({
      'name': childName,
      'topics': '$topics',
      'subjects': '$subjects',
    });
  }

  String get weekRangeLabel {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 6));
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
