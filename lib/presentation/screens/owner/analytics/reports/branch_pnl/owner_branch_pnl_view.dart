import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';
import '../../widgets/analytics_pdf.dart';

/// Branch P&L report — network totals + overhead, then a ranked per-branch
/// profit breakdown (collected − direct expenses).
class OwnerBranchPnlView extends StatefulWidget {
  const OwnerBranchPnlView({super.key});

  @override
  State<OwnerBranchPnlView> createState() => _OwnerBranchPnlViewState();
}

class _OwnerBranchPnlViewState extends State<OwnerBranchPnlView> {
  late final OwnerBranchPnlController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerBranchPnlController>();
  }

  static const _green = Color(0xFF16A34A);
  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_branch_pnl_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      onExport: () => shareAnalyticsPdf(
        title: 'owner_report_branch_pnl_title'.tr,
        subtitle: controller.scopeLabel,
        kpis: controller.pdfKpis,
        sections: controller.pdfSections,
        filename: 'branch-pnl.pdf',
      ),
      children: (context) {
        final net = controller.netProfit;
        return [
          Row(
            children: [
              Expanded(child: _money('owner_report_pnl_collected',
                  controller.totalCollected, _green)),
              SizedBox(width: 10.w),
              Expanded(child: _money('owner_report_pnl_expenses',
                  controller.totalExpenses, _red)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _money('owner_report_pnl_overhead',
                  controller.overhead, const Color(0xFF7C3AED))),
              SizedBox(width: 10.w),
              Expanded(child: _money('owner_report_pnl_net', net,
                  net < 0 ? _red : const Color(0xFF2563EB))),
            ],
          ),
          if (controller.isNetwork && controller.branches.isNotEmpty) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_pnl_by_branch',
              color: _green,
            ),
            for (final b in controller.branches)
              AnalyticsBarRow(
                label: b.branchName,
                trailing:
                    '${formatMoney(b.directProfit)} ${'owner_currency'.tr}',
                fill: b.current.collected / controller.maxCollected,
                color: b.directProfit < 0 ? _red : _green,
                subtitle:
                    '${'owner_report_pnl_collected'.tr}: ${formatMoney(b.current.collected)} · '
                    '${'owner_report_pnl_expenses'.tr}: ${formatMoney(b.current.expenses)}',
              ),
          ],
        ];
      },
    );
  }

  Widget _money(String key, double v, Color c) => AnalyticsStatTile(
        labelKey: key,
        value: formatMoney(v),
        unitKey: 'owner_currency',
        color: c,
      );
}
