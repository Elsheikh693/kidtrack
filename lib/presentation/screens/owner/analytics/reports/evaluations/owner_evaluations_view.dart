import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Child Evaluations report — 30-day evaluation volume, mean score on the
/// nursery's own scale, and the distribution across evaluation levels.
class OwnerEvaluationsView extends StatefulWidget {
  const OwnerEvaluationsView({super.key});

  @override
  State<OwnerEvaluationsView> createState() => _OwnerEvaluationsViewState();
}

class _OwnerEvaluationsViewState extends State<OwnerEvaluationsView> {
  late final OwnerEvaluationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerEvaluationsController>();
  }

  static const _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_evaluations_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        final total = controller.totalEvals.value;
        if (total == 0) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_eval_empty'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        final dist = controller.distribution;
        final maxCount = dist.isEmpty
            ? 1
            : dist.map((e) => e.count).reduce((a, b) => a > b ? a : b);
        return [
          Text(
            'owner_report_eval_window_note'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eval_total',
                value: '$total',
                color: const Color(0xFF2563EB),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_eval_avg',
                value: controller.avgScore.value.toStringAsFixed(1),
                color: _amber,
              )),
            ],
          ),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_eval_distribution',
            color: _amber,
          ),
          for (final e in dist)
            AnalyticsBarRow(
              label: e.title,
              trailing: '${e.count}',
              fill: e.count / maxCount,
              color: e.color,
            ),
        ];
      },
    );
  }
}
