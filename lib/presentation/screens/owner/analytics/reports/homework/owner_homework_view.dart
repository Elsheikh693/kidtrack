import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Homework Engagement report — last-30-day submission volume, reach, and the
/// "how did it go" quality signal from parents.
class OwnerHomeworkView extends StatefulWidget {
  const OwnerHomeworkView({super.key});

  @override
  State<OwnerHomeworkView> createState() => _OwnerHomeworkViewState();
}

class _OwnerHomeworkViewState extends State<OwnerHomeworkView> {
  late final OwnerHomeworkController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerHomeworkController>();
  }

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_homework_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty()];
        return [
          Row(children: [
            Expanded(child: _count('owner_report_hw_submissions',
                controller.submissions, _green)),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_hw_easy_rate',
                value: '${controller.didEasilyRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF2563EB),
              ),
            ),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _count('owner_report_hw_covered',
                controller.homeworkCovered, const Color(0xFF64748B))),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_hw_children',
                controller.childrenSubmitting, const Color(0xFF7C3AED))),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_hw_quality',
            color: _green,
          ),
          for (final q in controller.quality)
            AnalyticsBarRow(
              label: q.labelKey.tr,
              trailing: '${q.count}',
              fill: controller.shareOf(q.count),
              color: q.color,
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
            'owner_report_hw_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );
}
