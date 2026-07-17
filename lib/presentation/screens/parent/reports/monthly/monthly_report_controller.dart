import '../../../../../index/index_main.dart';
import '../../../../../Global/services/parent_education_service.dart';

/// Aggregates attendance, teacher evaluation and payments for a whole calendar
/// month into one parent-facing overview.
class MonthlyReportController extends GetxController {
  late final ChildAttendanceParentService _attendanceSvc;
  late final FinancialTransactionParentService _txSvc;
  late final ChildParentService _childSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;
  final _eduSvc = ParentEducationService();

  final isLoading = true.obs;
  final monthOffset = 0.obs; // 0 = current month, -1 = last month, …

  // Attendance
  final attendanceRate = 0.obs;
  final presentCount = 0.obs;
  final lateCount = 0.obs;
  final absentCount = 0.obs;
  final schoolDays = 0.obs;

  // Evaluation (3-level teacher scale, sourced from activity evaluations)
  final assessedCount = 0.obs; // evaluated activities this month
  final excellentCount = 0.obs;
  final needsFollowCount = 0.obs;
  final needsAttentionCount = 0.obs;
  final dominant = EvalLevel.excellent.obs;

  // Financial
  final monthPaid = 0.0.obs;

  final insight = ''.obs;
  final isEmptyMonth = false.obs;

  static const _historyMonths = 12;

  String childName = '';
  String _childId = '';
  String _classroomId = '';
  List<int> _workingDays = const [1, 2, 3, 4, 6, 7];
  final Map<String, ChildAttendanceModel> _attByDate = {};
  final _activities = <ClassroomActivityModel>[];
  final _transactions = <FinancialTransactionModel>[];

  String nurseryName = '';
  String? nurseryLogo;

  bool get canGoNext => monthOffset.value < 0;

  /// Attended days (present + late) — used by the hero summary.
  int get attendedDays => presentCount.value + lateCount.value;

  /// Total evaluated activities across the 3 levels.
  int get evalTotal =>
      excellentCount.value + needsFollowCount.value + needsAttentionCount.value;

  /// Number of payments recorded in the selected month.
  int get monthTxCount {
    final start = _monthStart;
    return _transactions.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      return d.year == start.year && d.month == start.month;
    }).length;
  }

  Color get statusColor {
    final r = attendanceRate.value;
    if (r >= 90) return const Color(0xFF16A34A);
    if (r >= 75) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String get statusLabelKey {
    final r = attendanceRate.value;
    if (r >= 90) return 'report_monthly_status_excellent';
    if (r >= 75) return 'report_monthly_status_good';
    return 'report_monthly_status_low';
  }

  @override
  void onInit() {
    super.onInit();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _txSvc = Get.find<FinancialTransactionParentService>();
    _childSvc = Get.find<ChildParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    _childId = _activeChild.childId.value;
    // Nursery, classroom, attendance and transactions are all independent and
    // run concurrently; activities depend on the resolved classroom id.
    final nurseryF = _loadNursery();
    final classroomF = _loadClassroom(_childId);
    final attendanceF = _loadAttendance(_childId);
    final txF = _loadTransactions(_childId);

    await classroomF;
    await _loadActivities();
    await nurseryF;
    await attendanceF;
    await txF;
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

  Future<void> _loadActivities() async {
    _activities.clear();
    if (_classroomId.isEmpty) return;
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (_historyMonths - 1), 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final list = await _eduSvc.getActivitiesForRange(
      nurseryId,
      _classroomId,
      startMs: start.millisecondsSinceEpoch,
      endMs: end.millisecondsSinceEpoch,
    );
    _activities.addAll(list.where((a) => a.evaluations.containsKey(_childId)));
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = _monthStart;
    final nextMonthStart = DateTime(start.year, start.month + 1, 1);
    final lastDay = nextMonthStart.subtract(const Duration(days: 1)).day;

    var present = 0, late = 0, absent = 0;

    for (var day = 1; day <= lastDay; day++) {
      final date = DateTime(start.year, start.month, day);
      if (date.isAfter(today)) break;
      if (!_workingDays.contains(date.weekday)) continue;
      final att = _attByDate[_dateKey(date)];
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
      } else if (date.isBefore(today)) {
        // Past working day with no check-in record → absent (attendance is
        // taken every working day). Today stays pending.
        absent++;
      }
    }

    final counted = present + late + absent;
    presentCount.value = present;
    lateCount.value = late;
    absentCount.value = absent;
    schoolDays.value = counted;
    attendanceRate.value =
        counted == 0 ? 0 : (((present + late) / counted) * 100).round();

    // Evaluation from activity evaluations within the month.
    final startMs = start.millisecondsSinceEpoch;
    final endMs = nextMonthStart.millisecondsSinceEpoch;
    var excellent = 0, needsFollow = 0, needsAttention = 0;
    for (final a in _activities) {
      if (a.startedAt < startMs || a.startedAt >= endMs) continue;
      final raw = a.evaluations[_childId];
      if (raw == null) continue;
      switch (EvalLevel.fromKey(raw)) {
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
    excellentCount.value = excellent;
    needsFollowCount.value = needsFollow;
    needsAttentionCount.value = needsAttention;
    assessedCount.value = excellent + needsFollow + needsAttention;
    dominant.value = _dominantOf(excellent, needsFollow, needsAttention);

    monthPaid.value = _transactions.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      return d.year == start.year && d.month == start.month;
    }).fold(0.0, (sum, t) => sum + t.amount);

    isEmptyMonth.value =
        counted == 0 && assessedCount.value == 0 && monthPaid.value == 0;
    _buildInsight();
  }

  EvalLevel _dominantOf(int ex, int nf, int na) {
    final total = ex + nf + na;
    if (total == 0) return EvalLevel.excellent;
    final score = (ex * 3 + nf * 2 + na * 1) / total;
    if (score >= 2.5) return EvalLevel.excellent;
    if (score >= 1.5) return EvalLevel.needsFollow;
    return EvalLevel.needsAttention;
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
