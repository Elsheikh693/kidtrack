import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Events report — event volume, upcoming count, total attendance, estimated
/// revenue, and the split by category.
class OwnerEventsView extends StatefulWidget {
  const OwnerEventsView({super.key});

  @override
  State<OwnerEventsView> createState() => _OwnerEventsViewState();
}

class _OwnerEventsViewState extends State<OwnerEventsView> {
  late final OwnerEventsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerEventsController>();
  }

  static const _indigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_events_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty()];
        return [
          Row(children: [
            Expanded(child: _count('owner_report_ev_total',
                '${controller.total}', _indigo)),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_ev_upcoming',
                '${controller.upcoming}', const Color(0xFF16A34A))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _count('owner_report_ev_attendees',
                '${controller.attendees}', const Color(0xFF0EA5E9))),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_ev_revenue',
                value: formatMoney(controller.estRevenue),
                unitKey: 'owner_currency',
                color: const Color(0xFFD97706),
              ),
            ),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_ev_by_category',
            color: _indigo,
          ),
          for (final c in controller.byCategory)
            AnalyticsBarRow(
              label: c.category.labelKey.tr,
              trailing: '${c.count}',
              fill: c.share,
              color: c.category.color,
            ),
        ];
      },
    );
  }

  Widget _count(String key, String v, Color c) =>
      AnalyticsStatTile(labelKey: key, value: v, color: c);

  Widget _empty() => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            'owner_report_ev_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );
}
