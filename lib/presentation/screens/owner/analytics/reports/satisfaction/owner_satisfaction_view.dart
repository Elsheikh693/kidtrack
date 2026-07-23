import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Parent Satisfaction report — average star rating, the happy/unhappy split,
/// the star distribution and the most-cited tags. Network-level (no scope pill).
class OwnerSatisfactionView extends StatefulWidget {
  const OwnerSatisfactionView({super.key});

  @override
  State<OwnerSatisfactionView> createState() => _OwnerSatisfactionViewState();
}

class _OwnerSatisfactionViewState extends State<OwnerSatisfactionView> {
  late final OwnerSatisfactionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerSatisfactionController>();
  }

  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_satisfaction_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      showScope: false,
      children: (context) {
        if (controller.responseCount == 0) return [_empty()];
        return [
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_sat_avg',
                value: controller.avgRating.toStringAsFixed(1),
                unitKey: 'owner_report_sat_of5',
                color: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_sat_responses', controller.responseCount)),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_sat_happy',
                value: '${controller.satisfactionRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_sat_unhappy',
                value: '${controller.detractorRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFFEF4444),
              ),
            ),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_sat_distribution',
            color: _pink,
          ),
          for (final s in controller.ratingDistribution)
            AnalyticsBarRow(
              label: 'owner_report_sat_stars'.trParams({'n': '${s.stars}'}),
              trailing: '${s.count}',
              fill: s.share,
              color: _starColor(s.stars),
            ),
          if (controller.topTags.isNotEmpty) ...[
            SizedBox(height: 6.h),
            AnalyticsSectionHeader(
              titleKey: 'owner_report_sat_tags',
              color: _pink,
            ),
            for (final t in controller.topTags)
              AnalyticsBarRow(
                label: t.tag,
                trailing: '${t.count}',
                fill: controller.topTags.first.count == 0
                    ? 0
                    : t.count / controller.topTags.first.count,
                color: _pink,
              ),
          ],
        ];
      },
    );
  }

  Widget _count(String key, int n) =>
      AnalyticsStatTile(labelKey: key, value: '$n', color: const Color(0xFF64748B));

  Widget _empty() => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            'owner_report_sat_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _starColor(int stars) {
    if (stars >= 4) return const Color(0xFF16A34A);
    if (stars == 3) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
