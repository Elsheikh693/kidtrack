import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Revenue by Payment Method — this month's collected money split across cash /
/// InstaPay / e-wallet.
class OwnerRevenueMethodView extends StatefulWidget {
  const OwnerRevenueMethodView({super.key});

  @override
  State<OwnerRevenueMethodView> createState() => _OwnerRevenueMethodViewState();
}

class _OwnerRevenueMethodViewState extends State<OwnerRevenueMethodView> {
  late final OwnerRevenueMethodController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerRevenueMethodController>();
  }

  Color _color(String method) {
    switch (method) {
      case 'instapay':
        return const Color(0xFF6D4AFF);
      case 'wallet':
        return const Color(0xFF16A34A);
      case 'cash':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_revenue_method_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final slices = controller.slices;
        return [
          AnalyticsStatTile(
            labelKey: 'owner_report_rm_total',
            value: formatMoney(controller.total),
            unitKey: 'owner_currency',
            color: const Color(0xFF2563EB),
          ),
          if (slices.isEmpty)
            _empty(context)
          else ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_rm_breakdown',
              color: Color(0xFF6D4AFF),
            ),
            for (final s in slices)
              AnalyticsBarRow(
                label: controller.labelFor(s.method),
                trailing: '${controller.percentOf(s.amount)}%',
                fill: controller.total <= 0 ? 0 : s.amount / controller.total,
                color: _color(s.method),
                subtitle: '${formatMoney(s.amount)} ${'owner_currency'.tr}',
              ),
          ],
        ];
      },
    );
  }

  Widget _empty(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'owner_report_no_data'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );
}
