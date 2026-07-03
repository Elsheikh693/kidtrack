import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';

/// Manager's finance tab — the SAME shared dashboard as the owner, pinned to the
/// manager's own branch (scope = session.branchId). KPIs come from
/// [FinanceAnalyticsService] over [FinancialTransactionModel] + [ExpenseModel].
///
/// NOTE: [ManagerFinanceController] is intentionally left registered — the
/// manager HOME dashboard still reads its collected/outstanding aggregates. It
/// is removed only in Phase 4 (old-system teardown).
class ManagerFinanceTab extends StatelessWidget {
  const ManagerFinanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(
          title: 'manager_tab_finance'.tr,
          accent: AppColors.activityAmberBrand,
          onBack: () => Get.find<MainPageViewModel>().changePage(0),
        ),
        // The body is hosted in its own [Scaffold] — NOT placed directly under
        // the [Expanded] — on purpose. A [RefreshIndicator] that is a direct
        // descendant of a [Flexible]/[Expanded] trips a Flutter semantics
        // assertion (`!semantics.parentDataDirty`, framework issue #34990) when
        // this tab is swapped in via the manager's IndexedStack. The Scaffold's
        // body builder sits between the Expanded and the RefreshIndicator and
        // breaks that chain — the same structure the owner finance tab uses.
        Expanded(
          child: Scaffold(
            backgroundColor: AppColors.backgroundNeutral100,
            body: const FinanceDashboardBody(tag: 'manager_finance'),
          ),
        ),
      ],
    );
  }
}
