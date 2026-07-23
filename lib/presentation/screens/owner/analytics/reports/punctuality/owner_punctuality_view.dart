import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Operational Punctuality report — timetable slots vs actual session starts:
/// on-time rate, average delay, and the punctuality distribution.
class OwnerPunctualityView extends StatefulWidget {
  const OwnerPunctualityView({super.key});

  @override
  State<OwnerPunctualityView> createState() => _OwnerPunctualityViewState();
}

class _OwnerPunctualityViewState extends State<OwnerPunctualityView> {
  late final OwnerPunctualityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerPunctualityController>();
  }

  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_punctuality_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty()];
        return [
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pu_ontime_rate',
                value: '${controller.onTimeRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pu_avg_delay',
                value: '${controller.avgDelay}',
                unitKey: 'owner_report_pu_min',
                color: _delayColor(controller.avgDelay),
              ),
            ),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _count('owner_report_pu_slots',
                controller.scheduledSlots, const Color(0xFF64748B))),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_pu_sessions',
                controller.sessionsRun, const Color(0xFF0EA5E9))),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_pu_matched',
                controller.matchedSessions, _purple)),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_pu_distribution',
            color: _purple,
          ),
          for (final b in controller.distribution)
            AnalyticsBarRow(
              label: b.labelKey.tr,
              trailing: '${b.count}',
              fill: b.share,
              color: _bucketColor(b.labelKey),
            ),
        ];
      },
    );
  }

  Widget _count(String key, int n, Color c) =>
      AnalyticsStatTile(labelKey: key, value: '$n', color: c);

  Widget _empty() => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            'owner_report_pu_empty'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _delayColor(int min) {
    if (min <= 5) return const Color(0xFF16A34A);
    if (min <= 15) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _bucketColor(String key) {
    if (key.endsWith('ontime')) return const Color(0xFF16A34A);
    if (key.endsWith('very_late')) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }
}
