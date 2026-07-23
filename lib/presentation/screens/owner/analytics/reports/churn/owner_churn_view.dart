import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';
import 'widgets/churn_child_tile.dart';

/// Withdrawals & Churn report — this month's departure count, a ranked reason
/// breakdown, then the list of withdrawn children with their exit reasons.
class OwnerChurnView extends StatefulWidget {
  const OwnerChurnView({super.key});

  @override
  State<OwnerChurnView> createState() => _OwnerChurnViewState();
}

class _OwnerChurnViewState extends State<OwnerChurnView> {
  late final OwnerChurnController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerChurnController>();
  }

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_churn_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final list = controller.withdrawals;
        if (list.isEmpty) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_churn_empty'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        final reasons = controller.reasons;
        final maxCount = reasons.first.count;
        return [
          AnalyticsStatTile(
            labelKey: 'owner_report_churn_total',
            value: '${controller.total}',
            color: _orange,
          ),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_churn_reasons',
            color: _orange,
          ),
          for (final r in reasons)
            AnalyticsBarRow(
              label: r.label,
              trailing: '${r.count}',
              fill: r.count / maxCount,
              color: _orange,
            ),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_churn_list',
            color: _orange,
          ),
          for (final w in list) ChurnChildTile(entry: w),
        ];
      },
    );
  }
}
