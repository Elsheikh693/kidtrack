import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';
import 'widgets/engagement_parent_tile.dart';

/// Parent Engagement report — activation funnel and app-usage telemetry, with a
/// leaderboard of the most-engaged parents. Network-level (no branch switcher).
class OwnerEngagementView extends StatefulWidget {
  const OwnerEngagementView({super.key});

  @override
  State<OwnerEngagementView> createState() => _OwnerEngagementViewState();
}

class _OwnerEngagementViewState extends State<OwnerEngagementView> {
  late final OwnerEngagementController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerEngagementController>();
  }

  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_engagement_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.total == 0) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_empty_generic'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        final board = controller.leaderboard;
        return [
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eng_activated',
                value: '${controller.activated}',
                color: const Color(0xFF16A34A),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eng_pending',
                value: '${controller.pending}',
                color: const Color(0xFFD97706),
              )),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eng_activity_views',
                value: '${controller.totalActivityViews}',
                color: const Color(0xFF2563EB),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eng_feed_views',
                value: '${controller.totalFeedViews}',
                color: _pink,
              )),
            ],
          ),
          SizedBox(height: 14.h),
          AnalyticsBarRow(
            label: 'owner_report_eng_activation_rate'.tr,
            trailing: '${controller.activationPercent}%',
            fill: controller.activationPercent / 100,
            color: const Color(0xFF16A34A),
            subtitle: '${controller.activated} / ${controller.total}',
          ),
          if (board.isNotEmpty) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_eng_leaderboard',
              color: _pink,
            ),
            for (var i = 0; i < board.length; i++)
              EngagementParentTile(rank: i + 1, parent: board[i]),
          ],
        ];
      },
    );
  }
}
