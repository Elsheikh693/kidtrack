import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Revenue by Package / Category — which fee categories brought the most money
/// this month.
class OwnerRevenueCategoryView extends StatefulWidget {
  const OwnerRevenueCategoryView({super.key});

  @override
  State<OwnerRevenueCategoryView> createState() =>
      _OwnerRevenueCategoryViewState();
}

class _OwnerRevenueCategoryViewState extends State<OwnerRevenueCategoryView> {
  late final OwnerRevenueCategoryController controller;

  static const _palette = [
    Color(0xFF16A34A),
    Color(0xFF6D4AFF),
    Color(0xFF0EA5E9),
    Color(0xFFD97706),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF0891B2),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerRevenueCategoryController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_revenue_category_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final cats = controller.categories;
        return [
          AnalyticsStatTile(
            labelKey: 'owner_report_rc_total',
            value: formatMoney(controller.total),
            unitKey: 'owner_currency',
            color: const Color(0xFF2563EB),
          ),
          if (cats.isEmpty)
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
              titleKey: 'owner_report_rc_breakdown',
              color: Color(0xFF16A34A),
            ),
            for (var i = 0; i < cats.length; i++)
              AnalyticsBarRow(
                label: cats[i].name,
                trailing: '${controller.percentOf(cats[i].amount)}%',
                fill: controller.total <= 0 ? 0 : cats[i].amount / controller.total,
                color: _palette[i % _palette.length],
                subtitle: '${formatMoney(cats[i].amount)} ${'owner_currency'.tr}',
              ),
          ],
        ];
      },
    );
  }
}
