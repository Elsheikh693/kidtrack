import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Revenue Forecast — next month's expected fees from active enrollments ×
/// package price, plus the per-package contribution.
class OwnerRevenueForecastView extends StatefulWidget {
  const OwnerRevenueForecastView({super.key});

  @override
  State<OwnerRevenueForecastView> createState() =>
      _OwnerRevenueForecastViewState();
}

class _OwnerRevenueForecastViewState extends State<OwnerRevenueForecastView> {
  late final OwnerRevenueForecastController controller;

  static const _palette = [
    Color(0xFF16A34A),
    Color(0xFF6D4AFF),
    Color(0xFF0EA5E9),
    Color(0xFFD97706),
    Color(0xFFEC4899),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerRevenueForecastController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_revenue_forecast_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final pkgs = controller.byPackage;
        final maxAmt = pkgs.isEmpty ? 1.0 : pkgs.first.amount;
        return [
          AnalyticsStatTile(
            labelKey: 'owner_report_rf_forecast',
            value: formatMoney(controller.forecast),
            unitKey: 'owner_currency',
            color: const Color(0xFF16A34A),
          ),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_rf_billable',
                value: '${controller.billableCount}',
                color: const Color(0xFF2563EB),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_rf_avg_fee',
                value: formatMoney(controller.avgFee),
                unitKey: 'owner_currency',
                color: const Color(0xFF6D4AFF),
              ),
            ),
          ]),
          if (pkgs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Center(
                child: Text(
                  'owner_report_no_data'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ),
            )
          else ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_rf_by_package',
              color: Color(0xFF16A34A),
            ),
            for (var i = 0; i < pkgs.length; i++)
              AnalyticsBarRow(
                label: pkgs[i].name,
                trailing:
                    '${pkgs[i].subscribers} ${'owner_report_rf_children'.tr}',
                fill: maxAmt <= 0 ? 0 : pkgs[i].amount / maxAmt,
                color: _palette[i % _palette.length],
                subtitle: '${formatMoney(pkgs[i].amount)} ${'owner_currency'.tr}',
              ),
          ],
        ];
      },
    );
  }
}
