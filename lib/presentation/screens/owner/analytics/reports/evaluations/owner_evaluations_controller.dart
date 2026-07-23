import '../../../../../../index/index_main.dart';

/// One evaluation level with how many times it was given — powers the
/// distribution breakdown. Carries the resolved title/color/score so the view
/// stays a pure renderer.
class EvalLevelCount {
  final String title;
  final Color color;
  final double score;
  final int count;
  const EvalLevelCount(this.title, this.color, this.score, this.count);
}

/// Child Evaluations report — the nursery's evaluation quality over the last 30
/// days: how many per-child evaluations teachers recorded, the mean score on the
/// nursery's own eval scale, and the distribution across levels. Network-level.
class OwnerEvaluationsController extends GetxController {
  late final ClassroomParentService _classrooms;
  late final TeacherActivityService _activity;
  late final EvalLevelsRegistry _registry;
  final SessionService _session = SessionService();

  final RxBool isLoading = false.obs;
  final RxInt totalEvals = 0.obs;
  final RxDouble avgScore = 0.0.obs;
  final RxList<EvalLevelCount> distribution = <EvalLevelCount>[].obs;

  static const int _windowDays = 30;

  @override
  void onInit() {
    super.onInit();
    _classrooms = Get.find<ClassroomParentService>();
    _activity = Get.find<TeacherActivityService>();
    _registry = Get.find<EvalLevelsRegistry>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      await _registry.ensureLoaded();
      final classroomIds = await _fetchClassroomIds();
      if (classroomIds.isEmpty) {
        _reset();
        return;
      }
      final now = DateTime.now();
      final startMs = now
          .subtract(const Duration(days: _windowDays))
          .millisecondsSinceEpoch;
      final acts = await _activity.getCompletedForClassrooms(
        _session.nurseryId ?? '',
        classroomIds,
        startMs: startMs,
        endMs: now.millisecondsSinceEpoch,
      );
      _aggregate(acts);
    } finally {
      isLoading.value = false;
    }
  }

  void _aggregate(List<ClassroomActivityModel> acts) {
    final byKey = <String, int>{};
    var count = 0;
    var sum = 0.0;
    for (final a in acts) {
      a.evaluations.forEach((_, key) {
        count++;
        sum += _registry.scoreFor(key);
        byKey[key] = (byKey[key] ?? 0) + 1;
      });
    }
    totalEvals.value = count;
    avgScore.value = count == 0 ? 0 : sum / count;
    final list = byKey.entries
        .map((e) => EvalLevelCount(
              _registry.titleFor(e.key),
              _registry.colorFor(e.key),
              _registry.scoreFor(e.key),
              e.value,
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    distribution.assignAll(list);
  }

  void _reset() {
    totalEvals.value = 0;
    avgScore.value = 0;
    distribution.clear();
  }

  Future<List<String>> _fetchClassroomIds() {
    final c = Completer<List<String>>();
    _classrooms.getAll(callBack: (list) {
      if (c.isCompleted) return;
      c.complete(list
          .whereType<ClassroomModel>()
          .where((cl) => cl.isActive && cl.key != null)
          .map((cl) => cl.key!)
          .toList());
    });
    return c.future;
  }
}
