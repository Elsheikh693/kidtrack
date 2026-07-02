import '../../../../index/index_main.dart';
import 'models/owner_dashboard_data.dart';
import 'models/monthly_finance_point.dart';
import 'widgets/executive_widgets.dart';
import 'widgets/finance_month_widgets.dart';
import 'widgets/owner_exec_shimmer.dart';

/// Owner's finance tab — a calm, READ-ONLY financial overview driven by a single
/// PRIMARY filter: the month selector at the very top. Picking a month re-renders
/// the whole screen for that month: its summary and its comparison to the
/// previous month. Per-scope (network or a single branch) via the executive
/// controller's cached metrics.
class OwnerFinanceTab extends StatefulWidget {
  const OwnerFinanceTab({super.key});

  @override
  State<OwnerFinanceTab> createState() => _OwnerFinanceTabState();
}

class _OwnerFinanceTabState extends State<OwnerFinanceTab> {
  late final OwnerExecutiveController controller;

  /// Selected month as year*100+month; null means "the latest month".
  int? _selectedYM;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerExecutiveController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(title: 'owner_tab_finance'.tr),
      body: Obx(() {
        final data = controller.data.value;
        final firstLoading = controller.isFirstLoading.value;

        return RefreshIndicator(
          onRefresh: controller.reload,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (firstLoading && data == null)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 110),
                  sliver: SliverToBoxAdapter(child: OwnerExecShimmer()),
                )
              else if (data != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(_sections(data)),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _sections(OwnerDashboardData data) {
    final trend = data.financeTrend;
    if (trend.isEmpty) return [_EmptyHint()];

    final selected = _resolveIndex(trend);
    final point = trend[selected];
    final prev = selected > 0 ? trend[selected - 1] : null;

    return [
      // ── PRIMARY filter: the month selector ──────────────────────────────────
      FinanceMonthSelector(
        point: point,
        onTap: () => _pickMonth(trend, selected),
      ),

      // ── Selected month at a glance ──────────────────────────────────────────
      const ExecSectionLabel(
        titleKey: 'owner_fin_summary_section',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF16A34A),
      ),
      FinanceMonthSummaryCard(point: point),

      // ── Compared to previous month ──────────────────────────────────────────
      if (prev != null) ...[
        const SizedBox(height: 12),
        FinanceMonthComparisonCard(current: point, previous: prev),
      ],
    ];
  }

  int _resolveIndex(List<MonthlyFinancePoint> trend) {
    if (_selectedYM == null) return trend.length - 1;
    final i =
        trend.indexWhere((p) => p.year * 100 + p.month == _selectedYM);
    return i >= 0 ? i : trend.length - 1;
  }

  void _select(List<MonthlyFinancePoint> trend, int index) {
    if (index < 0 || index >= trend.length) return;
    setState(() =>
        _selectedYM = trend[index].year * 100 + trend[index].month);
  }

  Future<void> _pickMonth(
      List<MonthlyFinancePoint> trend, int selected) async {
    final result =
        await showFinanceMonthPicker(points: trend, selectedIndex: selected);
    if (result != null) _select(trend, result);
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'owner_fin_empty'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondaryParagraph,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
