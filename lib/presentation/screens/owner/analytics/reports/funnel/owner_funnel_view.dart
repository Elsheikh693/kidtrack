import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Recruitment Funnel report — applications → waiting list → enrollments, with
/// the end-to-end conversion rate and the application-outcome split.
class OwnerFunnelView extends StatefulWidget {
  const OwnerFunnelView({super.key});

  @override
  State<OwnerFunnelView> createState() => _OwnerFunnelViewState();
}

class _OwnerFunnelViewState extends State<OwnerFunnelView> {
  late final OwnerFunnelController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerFunnelController>();
  }

  static const _teal = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_funnel_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty('owner_report_fn_empty')];
        return [
          Row(children: [
            Expanded(child: _count('owner_report_fn_applications',
                controller.applications, _teal)),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_fn_waiting',
                controller.waitingActive, const Color(0xFFF59E0B))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _count('owner_report_fn_enrolled',
                controller.enrolled, const Color(0xFF16A34A))),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_fn_conversion',
                value: '${controller.conversionRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF2563EB),
              ),
            ),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_fn_stages',
            color: _teal,
          ),
          for (final s in controller.stages)
            AnalyticsBarRow(
              label: s.labelKey.tr,
              trailing: '${s.count}',
              fill: s.share,
              color: _teal,
            ),
          SizedBox(height: 6.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_fn_outcomes',
            color: _teal,
          ),
          for (final s in controller.appStatus)
            AnalyticsBarRow(
              label: s.labelKey.tr,
              trailing: '${s.count}',
              fill: s.share,
              color: _outcomeColor(s.labelKey),
            ),
        ];
      },
    );
  }

  Widget _count(String key, int n, Color c) =>
      AnalyticsStatTile(labelKey: key, value: '$n', color: c);

  Widget _empty(String key) => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            key.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _outcomeColor(String key) {
    if (key.endsWith('approved')) return const Color(0xFF16A34A);
    if (key.endsWith('rejected')) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }
}
