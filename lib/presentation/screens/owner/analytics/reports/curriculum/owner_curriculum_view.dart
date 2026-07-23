import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Curriculum Coverage report — active topics vs completed, average coverage,
/// and a per-classroom breakdown (least-covered first).
class OwnerCurriculumView extends StatefulWidget {
  const OwnerCurriculumView({super.key});

  @override
  State<OwnerCurriculumView> createState() => _OwnerCurriculumViewState();
}

class _OwnerCurriculumViewState extends State<OwnerCurriculumView> {
  late final OwnerCurriculumController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerCurriculumController>();
  }

  static const _blue = Color(0xFF0EA5E9);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_curriculum_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty()];
        return [
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_cu_coverage',
                value: '${controller.avgCoverage}',
                unitKey: 'owner_percent_unit',
                color: _blue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_cu_completed',
                controller.completed, const Color(0xFF16A34A))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _count('owner_report_cu_topics',
                controller.activeTopics, const Color(0xFF64748B))),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_cu_classrooms',
                controller.classroomsCovered, const Color(0xFF7C3AED))),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_cu_by_classroom',
            color: _blue,
          ),
          for (final r in controller.byClassroom)
            AnalyticsBarRow(
              label: r.classroom,
              trailing: '${(r.share * 100).round()}%',
              fill: r.share,
              color: _coverColor(r.share),
              subtitle: 'owner_report_cu_done'.trParams({'n': '${r.done}'}),
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
            'owner_report_cu_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _coverColor(double share) {
    if (share >= 0.66) return const Color(0xFF16A34A);
    if (share >= 0.33) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
