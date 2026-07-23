import '../../../../../index/index_main.dart';
import '../../../../../Global/services/parent_education_service.dart';

/// One working day inside the evaluation week — the day's aggregated teacher
/// evaluation (dominant level across that day's assessed activities).
class EvalDay {
  final DateTime date;
  final bool assessed;
  final EvalLevel? level;
  final int count; // number of evaluated activities that day

  const EvalDay({
    required this.date,
    required this.assessed,
    this.level,
    this.count = 0,
  });

  String get dayKey => const {
        1: 'report_day_mon',
        2: 'report_day_tue',
        3: 'report_day_wed',
        4: 'report_day_thu',
        5: 'report_day_fri',
        6: 'report_day_sat',
        7: 'report_day_sun',
      }[date.weekday]!;
}

class _WeekEval {
  final List<EvalDay> days;
  final int excellent;
  final int needsFollow;
  final int needsAttention;
  final int assessedDays;

  const _WeekEval({
    required this.days,
    required this.excellent,
    required this.needsFollow,
    required this.needsAttention,
    required this.assessedDays,
  });

  int get evalCount => excellent + needsFollow + needsAttention;
  bool get isEmpty => evalCount == 0;

  /// Weighted average on a 1–3 scale (3 = excellent).
  double get avgScore {
    if (evalCount == 0) return 0;
    final total = excellent * 3 + needsFollow * 2 + needsAttention * 1;
    return total / evalCount;
  }

  EvalLevel get dominant {
    if (avgScore >= 2.5) return EvalLevel.excellent;
    if (avgScore >= 1.5) return EvalLevel.needsFollow;
    return EvalLevel.needsAttention;
  }
}

class WeeklyEvaluationController extends GetxController {
  late final ChildParentService _childSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;
  final _eduSvc = ParentEducationService();

  final isLoading = true.obs;
  final weekOffset = 0.obs;

  final days = <EvalDay>[].obs;
  final evalCount = 0.obs; // total activity evaluations this week
  final assessedCount = 0.obs; // working days that were assessed
  final workingDaysCount = 0.obs;
  final excellentCount = 0.obs;
  final needsFollowCount = 0.obs;
  final needsAttentionCount = 0.obs;
  final dominant = EvalLevel.excellent.obs;
  final isEmptyWeek = false.obs;
  final insight = ''.obs;

  static const _historyWeeks = 12;

  String childName = '';
  String _childId = '';
  String _classroomId = '';
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];
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
        _workingDays = n.effectiveWorkingDays;
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
    // Keep only activities where this child was actually evaluated.
    _activities.addAll(list.where((a) => a.evaluations.containsKey(_childId)));
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

  void _recompute() {
    final stats = _computeWeek(weekOffset.value);
    days.value = stats.days;
    workingDaysCount.value =
        stats.days.where((d) => !d.date.isAfter(_today())).length;
    evalCount.value = stats.evalCount;
    assessedCount.value = stats.assessedDays;
    excellentCount.value = stats.excellent;
    needsFollowCount.value = stats.needsFollow;
    needsAttentionCount.value = stats.needsAttention;
    dominant.value = stats.dominant;
    isEmptyWeek.value = stats.isEmpty;
    _buildInsight(stats);
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime _weekStart(int offset) {
    final today = _today();
    final daysSinceSat = (today.weekday - DateTime.saturday + 7) % 7;
    return today.subtract(Duration(days: daysSinceSat - offset * 7));
  }

  _WeekEval _computeWeek(int offset) {
    final today = _today();
    final start = _weekStart(offset);
    final end = start.add(const Duration(days: 7));
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    // Bucket this week's evaluations by calendar day.
    final byDay = <int, List<EvalLevel>>{};
    for (final a in _activities) {
      final when = a.startedAt;
      if (when < startMs || when >= endMs) continue;
      final raw = a.evaluations[_childId];
      if (raw == null) continue;
      final d = DateTime.fromMillisecondsSinceEpoch(when);
      final dayKey = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      byDay.putIfAbsent(dayKey, () => []).add(EvalLevel.fromKey(raw));
    }

    final result = <EvalDay>[];
    var excellent = 0, needsFollow = 0, needsAttention = 0, assessedDays = 0;

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      if (!_workingDays.contains(date.weekday)) continue;
      if (date.isAfter(today)) {
        result.add(EvalDay(date: date, assessed: false));
        continue;
      }
      final levels = byDay[date.millisecondsSinceEpoch];
      if (levels == null || levels.isEmpty) {
        result.add(EvalDay(date: date, assessed: false));
        continue;
      }
      for (final lv in levels) {
        switch (lv) {
          case EvalLevel.excellent:
            excellent++;
            break;
          case EvalLevel.needsFollow:
            needsFollow++;
            break;
          case EvalLevel.needsAttention:
            needsAttention++;
            break;
        }
      }
      assessedDays++;
      result.add(EvalDay(
        date: date,
        assessed: true,
        level: _dominantOf(levels),
        count: levels.length,
      ));
    }

    return _WeekEval(
      days: result,
      excellent: excellent,
      needsFollow: needsFollow,
      needsAttention: needsAttention,
      assessedDays: assessedDays,
    );
  }

  EvalLevel _dominantOf(List<EvalLevel> levels) {
    if (levels.isEmpty) return EvalLevel.excellent;
    var total = 0;
    for (final lv in levels) {
      total += switch (lv) {
        EvalLevel.excellent => 3,
        EvalLevel.needsFollow => 2,
        EvalLevel.needsAttention => 1,
      };
    }
    final avg = total / levels.length;
    if (avg >= 2.5) return EvalLevel.excellent;
    if (avg >= 1.5) return EvalLevel.needsFollow;
    return EvalLevel.needsAttention;
  }

  void _buildInsight(_WeekEval stats) {
    if (stats.isEmpty) {
      insight.value = '';
      return;
    }
    final name = childName;
    if (stats.needsAttention >= 2 && stats.dominant == EvalLevel.needsAttention) {
      insight.value = 'report_eval_insight_support'.trParams({'name': name});
    } else if (stats.avgScore >= 2.5) {
      insight.value = 'report_eval_insight_excellent'.trParams({'name': name});
    } else if (stats.avgScore >= 1.5) {
      insight.value = 'report_eval_insight_good'.trParams({'name': name});
    } else {
      insight.value = 'report_eval_insight_neutral'.trParams({'name': name});
    }
  }

  String get weekRangeLabel {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 6));
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
