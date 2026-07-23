import '../../../../../../index/index_main.dart';

/// Staff Attendance & Payroll — the workforce cost view. Combines this month's
/// `StaffAttendanceModel` (punctuality), active `StaffModel.salary` (payroll),
/// and this month's collections (revenue) into the one ratio an owner watches:
/// payroll as a share of revenue. Scope-aware via the staff/attendance branchId.
class OwnerStaffCostController extends GetxController {
  late final OwnerReportsDataService _data;
  late final OwnerFinanceDataService _finance;
  late final OwnerScopeService _scope;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<OwnerReportsDataService>();
    _finance = Get.find<OwnerFinanceDataService>();
    _scope = Get.find<OwnerScopeService>();
    _data.ensureLoaded();
    _finance.ensureLoaded();
  }

  RxBool get firstLoading => _data.isFirstLoading;
  Future<void> reload() async {
    await Future.wait([_data.refresh(), _finance.refresh()]);
  }

  OwnerScope get _s => _scope.scope.value;
  DateTime get _month {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  // ── Payroll & revenue ───────────────────────────────────────────────────────

  List<StaffModel> get _staff => _data.activeStaffFor(_s);
  int get headcount => _staff.length;

  double get monthlyPayroll =>
      _staff.fold(0.0, (s, m) => s + (m.salary ?? 0));

  double get monthRevenue => _finance
      .collectionsFor(_s)
      .where((t) => OwnerFinanceDataService.inMonth(t.date, _month))
      .fold(0.0, (s, t) => s + t.amount);

  /// Payroll as a percentage of revenue — the headline cost ratio.
  int get payrollRatio {
    if (monthRevenue <= 0) return 0;
    return ((monthlyPayroll / monthRevenue) * 100).round();
  }

  // ── Attendance (this month) ─────────────────────────────────────────────────

  List<StaffAttendanceModel> get _monthAttendance => _data
      .staffAttendanceFor(_s)
      .where((a) => _isThisMonth(a.date))
      .toList();

  int get _records => _monthAttendance.length;

  int _countStatus(String s) =>
      _monthAttendance.where((a) => a.status == s).length;

  /// On-time share of all logged staff days.
  int get punctualityRate {
    if (_records == 0) return 0;
    return ((_countStatus('present') / _records) * 100).round();
  }

  int get pendingLeaves => _data.pendingLeavesFor(_s).length;

  /// Attendance status breakdown, present-first.
  List<StatusSlice> get attendanceBreakdown {
    const order = ['present', 'late', 'absent', 'on_leave'];
    const labelKeys = {
      'present': 'manager_staff_status_present',
      'late': 'manager_staff_status_late',
      'absent': 'manager_staff_status_absent',
      'on_leave': 'manager_staff_status_leave',
    };
    return order.map((k) {
      final n = _countStatus(k);
      return StatusSlice(
        labelKey: labelKeys[k]!,
        status: k,
        count: n,
        share: _records == 0 ? 0 : n / _records,
      );
    }).toList();
  }

  bool _isThisMonth(String ymd) {
    // date stored as "YYYY-MM-DD".
    final parts = ymd.split('-');
    if (parts.length < 2) return false;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return y == _month.year && m == _month.month;
  }
}

/// One bar in the attendance-status breakdown.
class StatusSlice {
  final String labelKey;
  final String status;
  final int count;
  final double share;
  const StatusSlice({
    required this.labelKey,
    required this.status,
    required this.count,
    required this.share,
  });
}
