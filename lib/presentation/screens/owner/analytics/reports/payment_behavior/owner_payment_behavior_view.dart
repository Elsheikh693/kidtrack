import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Payment Behaviour — on-time vs late settlement + repeat-late families.
class OwnerPaymentBehaviorView extends StatefulWidget {
  const OwnerPaymentBehaviorView({super.key});

  @override
  State<OwnerPaymentBehaviorView> createState() =>
      _OwnerPaymentBehaviorViewState();
}

class _OwnerPaymentBehaviorViewState extends State<OwnerPaymentBehaviorView> {
  late final OwnerPaymentBehaviorController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerPaymentBehaviorController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_payment_behavior_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final repeat = controller.repeatLate;
        final maxCount =
            repeat.isEmpty ? 1 : repeat.first.count;
        return [
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pb_ontime_rate',
                value: '${controller.onTimeRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pb_avg_days_late',
                value: '${controller.avgDaysLate}',
                unitKey: 'owner_report_pb_days_unit',
                color: const Color(0xFFD97706),
              ),
            ),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pb_ontime',
                value: '${controller.onTimeCount}',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pb_late',
                value: '${controller.lateCount}',
                color: const Color(0xFFEF4444),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_pb_repeat',
                value: '${repeat.length}',
                color: const Color(0xFFF97316),
              ),
            ),
          ]),
          if (repeat.isNotEmpty) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_pb_repeat_list',
              color: Color(0xFFF97316),
            ),
            for (final p in repeat)
              AnalyticsBarRow(
                label: p.name,
                trailing:
                    '${p.count} ${'owner_report_pb_times'.tr}',
                fill: p.count / maxCount,
                color: const Color(0xFFF97316),
              ),
          ],
        ];
      },
    );
  }
}
