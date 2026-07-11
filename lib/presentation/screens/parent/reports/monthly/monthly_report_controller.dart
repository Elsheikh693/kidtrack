import '../../../../../index/index_main.dart';

/// Aggregates attendance, teacher evaluation and payments for a whole calendar
/// month into one parent-facing overview.
class MonthlyReportController extends GetxController {
  late final ChildAttendanceParentService _attendanceSvc;
  late final DailyAssessmentParentService _assessmentSvc;
  late final FinancialTransactionParentService _txSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;

  final isLoading = true.obs;
  final monthOffset = 0.obs; // 0 = current month, -1 = last month, …

  // Attendance
  final attendanceRate = 0.obs;
  final presentCount = 0.obs;
  final lateCount = 0.obs;
  final absentCount = 0.obs;
  final schoolDays = 0.obs;

  // Evaluation
  final assessedCount = 0.obs;
  final excellentCount = 0.obs;
  final veryGoodCount = 0.obs;
  final goodCount = 0.obs;
  final needsSupportCount = 0.obs;
  final dominant = DailyRating.good.obs;

  // Financial
  final monthPaid = 0.0.obs;

  final insight = ''.obs;
  final isEmptyMonth = false.obs;

  String childName = '';
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];
  final Map<String, ChildAttendanceModel> _attByDate = {};
  final Map<String, DailyAssessmentModel> _evalByDate = {};
  final _transactions = <FinancialTransactionModel>[];

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => monthOffset.value < 0;

  @override
  void onInit() {
    super.onInit();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _assessmentSvc = Get.find<DailyAssessmentParentService>();
    _txSvc = Get.find<FinancialTransactionParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    final childId = _activeChild.childId.value;
    await _loadNursery();
    await _loadAttendance(childId);
    await _loadAssessments(childId);
    await _loadTransactions(childId);
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

  Future<void> _loadAttendance(String childId) async {
    _attByDate.clear();
    await _attendanceSvc.getAll(
      callBack: (list) {
        for (final a in list.whereType<ChildAttendanceModel>()) {
          if (a.childId == childId) _attByDate[a.date] = a;
        }
      },
    );
  }

  Future<void> _loadAssessments(String childId) async {
    _evalByDate.clear();
    await _assessmentSvc.getAll(
      callBack: (list) {
        for (final a in list.whereType<DailyAssessmentModel>()) {
          if (a.childId == childId) _evalByDate[a.date] = a;
        }
      },
    );
  }

  Future<void> _loadTransactions(String childId) async {
    _transactions.clear();
    if (childId.isEmpty) return;
    _transactions.addAll(await _txSvc.getByChild(childId));
  }

  void previousMonth() {
    monthOffset.value -= 1;
    _recompute();
  }

  void nextMonth() {
    if (!canGoNext) return;
    monthOffset.value += 1;
    _recompute();
  }

  DateTime get _monthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthOffset.value, 1);
  }

  void _recompute() {
    final today = DateTime.now();
    final start = _monthStart;
    final nextMonthStart = DateTime(start.year, start.month + 1, 1);
    final lastDay = nextMonthStart.subtract(const Duration(days: 1)).day;

    var present = 0, late = 0, absent = 0;
    var excellent = 0, veryGood = 0, good = 0, needsSupport = 0, assessed = 0;

    for (var day = 1; day <= lastDay; day++) {
      final date = DateTime(start.year, start.month, day);
      if (date.isAfter(DateTime(today.year, today.month, today.day))) break;
      if (!_workingDays.contains(date.weekday)) continue;
      final key = _dateKey(date);

      final att = _attByDate[key];
      if (att != null) {
        switch (att.status) {
          case 'present':
            present++;
            break;
          case 'late':
            late++;
            break;
          case 'absent':
            absent++;
            break;
        }
      }

      final ev = _evalByDate[key];
      if (ev != null) {
        assessed++;
        switch (ev.rating) {
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
      }
    }

    final counted = present + late + absent;
    presentCount.value = present;
    lateCount.value = late;
    absentCount.value = absent;
    schoolDays.value = counted;
    attendanceRate.value =
        counted == 0 ? 0 : (((present + late) / counted) * 100).round();

    assessedCount.value = assessed;
    excellentCount.value = excellent;
    veryGoodCount.value = veryGood;
    goodCount.value = good;
    needsSupportCount.value = needsSupport;
    dominant.value = _dominantOf(excellent, veryGood, good, needsSupport);

    monthPaid.value = _transactions.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      return d.year == start.year && d.month == start.month;
    }).fold(0.0, (sum, t) => sum + t.amount);

    isEmptyMonth.value = counted == 0 && assessed == 0 && monthPaid.value == 0;
    _buildInsight();
  }

  DailyRating _dominantOf(int ex, int vg, int gd, int ns) {
    final total = ex + vg + gd + ns;
    if (total == 0) return DailyRating.good;
    final score = (ex * 4 + vg * 3 + gd * 2 + ns * 1) / total;
    if (score >= 3.5) return DailyRating.excellent;
    if (score >= 2.5) return DailyRating.veryGood;
    if (score >= 1.5) return DailyRating.good;
    return DailyRating.needsSupport;
  }

  void _buildInsight() {
    if (isEmptyMonth.value) {
      insight.value = '';
      return;
    }
    insight.value = 'report_monthly_insight'.trParams({
      'name': childName,
      'rate': '${attendanceRate.value}',
    });
  }

  String _dateKey(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int v) => v.toString().padLeft(2, '0');

  /// Localized "Month Year" label for the selected month.
  String get monthLabel {
    final start = _monthStart;
    return '${'report_month_${start.month}'.tr} ${start.year}';
  }
}
