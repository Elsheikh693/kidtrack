import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../../executive/widgets/finance_trend_chart.dart';
import '../../../executive/widgets/finance_history_list.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_section_header.dart';
import '../../widgets/analytics_pdf.dart';

/// Finance Trend report — 12 months of collected vs expenses as a bar chart plus
/// a month-by-month history table. Chart and table share a selected month.
class OwnerFinanceTrendView extends StatefulWidget {
  const OwnerFinanceTrendView({super.key});

  @override
  State<OwnerFinanceTrendView> createState() => _OwnerFinanceTrendViewState();
}

class _OwnerFinanceTrendViewState extends State<OwnerFinanceTrendView> {
  late final OwnerFinanceTrendController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerFinanceTrendController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_finance_trend_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      onExport: () => shareAnalyticsPdf(
        title: 'owner_report_finance_trend_title'.tr,
        subtitle: controller.scopeLabel,
        kpis: controller.pdfKpis,
        sections: controller.pdfSections,
        filename: 'finance-trend.pdf',
      ),
      children: (context) {
        final points = controller.trend;
        if (points.isEmpty) {
          return [
            SizedBox(height: 120.h),
            Text(
              'owner_report_empty_generic'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        final sel = controller.selectedIndex;
        return [
          Row(
            children: [
              Expanded(child: _tile('owner_report_ft_collected',
                  controller.totalCollected, const Color(0xFF16A34A))),
              SizedBox(width: 10.w),
              Expanded(child: _tile('owner_report_ft_expenses',
                  controller.totalExpenses, const Color(0xFFEF4444))),
              SizedBox(width: 10.w),
              Expanded(child: _tile('owner_report_ft_profit',
                  controller.totalProfit,
                  controller.totalProfit < 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF2563EB))),
            ],
          ),
          SizedBox(height: 18.h),
          FinanceTrendChart(
            points: points,
            selectedIndex: sel,
            onTapMonth: controller.selectMonth,
          ),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_ft_history',
            color: Color(0xFF16A34A),
          ),
          FinanceHistoryList(
            points: points,
            selectedIndex: sel,
            onTapMonth: controller.selectMonth,
          ),
        ];
      },
    );
  }

  Widget _tile(String key, double value, Color color) => AnalyticsStatTile(
        labelKey: key,
        value: formatMoney(value),
        unitKey: 'owner_currency',
        color: color,
      );
}
