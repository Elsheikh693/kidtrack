import '../../../../index/index_main.dart';
import '../children/models/presence_entry.dart';

/// Executive overview for the Branch Manager. Owns no data of its own — it
/// aggregates the live signals from the Children, Staff and Finance controllers
/// into a single "problems first" snapshot and deep-links into each tab.
class ManagerDashboardController extends GetxController {
  late final ManagerChildrenController _children;
  late final ManagerStaffController _staff;
  late final ManagerFinanceController _finance;

  @override
  void onInit() {
    super.onInit();
    // Resolving these triggers their own onInit → loadData, so the dashboard
    // reflects real data even when it is the first tab the manager opens.
    _children = Get.find<ManagerChildrenController>();
    _staff = Get.find<ManagerStaffController>();
    _finance = Get.find<ManagerFinanceController>();
  }

  bool get isLoading =>
      _children.isLoading.value ||
      _staff.isLoading.value ||
      _finance.isLoading.value;

  // ─── Today snapshot ───────────────────────────────────────────────────────
  int get presentChildren => _children.presentNow.value;
  int get activeChildren => _children.activeChildren.value;
  int get occupancyRate => _children.occupancyRate.value;
  int get newThisMonth => _children.newThisMonth.value;
  int get staffPresent => _staff.presentToday.value;
  int get totalStaff => _staff.totalStaff.value;
  int get staffOnLeave => _staff.onLeaveToday.value;

  /// Active (enrolled, not on leave) children who have not checked in yet.
  int get absentChildren {
    final v = activeChildren - presentChildren;
    return v < 0 ? 0 : v;
  }

  /// Share of active children currently checked in (0–100).
  int get attendanceRate {
    if (activeChildren <= 0) return 0;
    return ((presentChildren / activeChildren) * 100).round().clamp(0, 100);
  }

  // ─── Live presence ────────────────────────────────────────────────────────
  List<PresenceEntry> get insideNow => _children.insideNow;
  List<PresenceEntry> get leftToday => _children.leftToday;

  /// Whether anyone has checked in today at all — the presence breakdown only
  /// makes sense once the day has some attendance to show.
  bool get hasAttendanceToday =>
      _children.insideNow.isNotEmpty || _children.leftToday.isNotEmpty;

  // ─── Financial summary ──────────────────────────────────────────────────────
  double get collectedThisMonth => _finance.collectedThisMonth.value;
  double get outstandingTotal => _finance.outstandingTotal.value;
  double get overdueTotal => _finance.overdueTotal.value;
  int get debtFamiliesCount => _finance.debtFamiliesCount.value;
  double get monthlyPayroll => _staff.totalPayroll.value;

  /// Share of this month's billable amount that has been collected (0–100).
  int get collectionRate {
    final billable = collectedThisMonth + outstandingTotal;
    if (billable <= 0) return 0;
    return ((collectedThisMonth / billable) * 100).round().clamp(0, 100);
  }

  void openTab(int index) => Get.find<MainPageViewModel>().changePage(index);

  /// Jump to the Children tab with its search field already open.
  void openChildrenSearch() {
    _children.openSearch();
    openTab(1);
  }

  /// Open a child's profile from the live presence list.
  void openChild(String childId) => _children.openChild(childId);

  Future<void> loadData() async {
    await Future.wait([
      _children.loadData(),
      _staff.loadData(),
      _finance.loadData(),
    ]);
  }
}
