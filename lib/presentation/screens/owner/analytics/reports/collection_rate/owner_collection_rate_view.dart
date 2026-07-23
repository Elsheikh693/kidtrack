import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';

/// Real Collection Rate report — billed vs collected against THIS month's
/// invoices, so the rate is enrollment-based (not the cash-log ~100%).
class OwnerCollectionRateView extends StatefulWidget {
  const OwnerCollectionRateView({super.key});

  @override
  State<OwnerCollectionRateView> createState() =>
      _OwnerCollectionRateViewState();
}

class _OwnerCollectionRateViewState extends State<OwnerCollectionRateView> {
  late final OwnerCollectionRateController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerCollectionRateController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_collection_rate_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) => [
        Row(children: [
          Expanded(
            child: AnalyticsStatTile(
              labelKey: 'owner_report_cr_rate',
              value: '${controller.ratePercent}',
              unitKey: 'owner_percent_unit',
              color: const Color(0xFF2563EB),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _money('owner_report_cr_expected', controller.expected,
                const Color(0xFFD97706)),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(
            child: _money('owner_report_cr_collected', controller.collected,
                const Color(0xFF16A34A)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _money('owner_report_cr_outstanding',
                controller.outstanding, const Color(0xFFEF4444)),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(child: _count('owner_report_cr_invoices', controller.invoiceCount)),
          SizedBox(width: 10.w),
          Expanded(child: _count('owner_report_cr_paid', controller.fullyPaidCount)),
          SizedBox(width: 10.w),
          Expanded(child: _count('owner_report_cr_unpaid', controller.unpaidCount)),
        ]),
      ],
    );
  }

  Widget _money(String key, double v, Color c) => AnalyticsStatTile(
        labelKey: key,
        value: formatMoney(v),
        unitKey: 'owner_currency',
        color: c,
      );

  Widget _count(String key, int n) => AnalyticsStatTile(
        labelKey: key,
        value: '$n',
        color: const Color(0xFF64748B),
      );
}
