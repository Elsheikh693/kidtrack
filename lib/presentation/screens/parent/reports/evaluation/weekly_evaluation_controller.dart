import '../../../../../index/index_main.dart';

/// One working day inside the evaluation week.
class EvalDay {
  final DateTime date;
  final bool assessed;
  final DailyRating? rating;
  final String? comment;

  const EvalDay({
    required this.date,
    required this.assessed,
    this.rating,
    this.comment,
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
  final int veryGood;
  final int good;
  final int needsSupport;

  const _WeekEval({
    required this.days,
    required this.excellent,
    required this.veryGood,
    required this.good,
    required this.needsSupport,
  });

  int get assessedCount => excellent + veryGood + good + needsSupport;
  bool get isEmpty => assessedCount == 0;

  /// Weighted average score on a 1–4 scale (4 = excellent).
  double get avgScore {
    if (assessedCount == 0) return 0;
    final total = excellent * 4 + veryGood * 3 + good * 2 + needsSupport * 1;
    return total / assessedCount;
  }

  DailyRating get dominant {
    if (avgScore >= 3.5) return DailyRating.excellent;
    if (avgScore >= 2.5) return DailyRating.veryGood;
    if (avgScore >= 1.5) return DailyRating.good;
    return DailyRating.needsSupport;
  }
}

class WeeklyEvaluationController extends GetxController {
  late final DailyAssessmentParentService _assessmentSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;

  final isLoading = true.obs;
  final weekOffset = 0.obs;

  final days = <EvalDay>[].obs;
  final assessedCount = 0.obs;
  final workingDaysCount = 0.obs;
  final excellentCount = 0.obs;
  final veryGoodCount = 0.obs;
  final goodCount = 0.obs;
  final needsSupportCount = 0.obs;
  final dominant = DailyRating.good.obs;
  final isEmptyWeek = false.obs;
  final insight = ''.obs;

  String childName = '';
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];
  final Map<String, DailyAssessmentModel> _byDate = {};

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => weekOffset.value < 0;

  @override
  void onInit() {
    super.onInit();
    _assessmentSvc = Get.find<DailyAssessmentParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    await _loadNursery();
    await _loadAssessments(_activeChild.childId.value);
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

  Future<void> _loadAssessments(String childId) async {
    _byDate.clear();
    await _assessmentSvc.getAll(
      callBack: (list) {
        for (final a in list.whereType<DailyAssessmentModel>()) {
          if (a.childId == childId) _byDate[a.date] = a;
        }
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

  void _recompute() {
    final stats = _computeWeek(weekOffset.value);
    days.value = stats.days;
    workingDaysCount.value = stats.days.where((d) => !d.date.isAfter(_today())).length;
    assessedCount.value = stats.assessedCount;
    excellentCount.value = stats.excellent;
    veryGoodCount.value = stats.veryGood;
    goodCount.value = stats.good;
    needsSupportCount.value = stats.needsSupport;
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
    final result = <EvalDay>[];
    var excellent = 0, veryGood = 0, good = 0, needsSupport = 0;

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      if (!_workingDays.contains(date.weekday)) continue;
      if (date.isAfter(today)) {
        result.add(EvalDay(date: date, assessed: false));
        continue;
      }
      final record = _byDate[_dateKey(date)];
      if (record == null) {
        result.add(EvalDay(date: date, assessed: false));
        continue;
      }
      switch (record.rating) {
        case DailyRating.excellent:
          excellent++;
          break;
        case DailyRating.veryGood:
          veryGood++;
          break;
        case DailyRating.good:
          good++;
          break;
        case DailyRating.needsSupport:
          needsSupport++;
          break;
      }
      result.add(EvalDay(
        date: date,
        assessed: true,
        rating: record.rating,
        comment: record.comment,
      ));
    }

    return _WeekEval(
      days: result,
      excellent: excellent,
      veryGood: veryGood,
      good: good,
      needsSupport: needsSupport,
    );
  }

  void _buildInsight(_WeekEval stats) {
    if (stats.isEmpty) {
      insight.value = '';
      return;
    }
    final name = childName;
    if (stats.needsSupport >= 2) {
      insight.value = 'report_eval_insight_support'.trParams({'name': name});
    } else if (stats.avgScore >= 3.5) {
      insight.value = 'report_eval_insight_excellent'.trParams({'name': name});
    } else if (stats.avgScore >= 2.5) {
      insight.value = 'report_eval_insight_good'.trParams({'name': name});
    } else {
      insight.value = 'report_eval_insight_neutral'.trParams({'name': name});
    }
  }

  String _dateKey(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int v) => v.toString().padLeft(2, '0');

  String get weekRangeLabel {
    final start = _weekStart(weekOffset.value);
    final end = start.add(const Duration(days: 6));
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
