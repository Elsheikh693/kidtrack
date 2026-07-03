import '../../../../index/index_main.dart';

/// Owner's finance tab — the shared finance DASHBOARD scoped to the whole
/// network (or a single branch via the [OwnerAppBar]'s scope switcher, which the
/// dashboard controller reacts to). All KPIs come from
/// [FinanceAnalyticsService] over [FinancialTransactionModel] + [ExpenseModel] —
/// the old Invoice-based finance trend is gone.
class OwnerFinanceTab extends StatelessWidget {
  const OwnerFinanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(title: 'owner_tab_finance'.tr),
      body: const FinanceDashboardBody(tag: 'owner_finance'),
    );
  }
}
