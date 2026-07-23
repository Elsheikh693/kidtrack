import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Academic Performance report — exam-results overview: average grade,
/// success/excellence rates, the grade mix and the subject ranking.
class OwnerAcademicView extends StatefulWidget {
  const OwnerAcademicView({super.key});

  @override
  State<OwnerAcademicView> createState() => _OwnerAcademicViewState();
}

class _OwnerAcademicViewState extends State<OwnerAcademicView> {
  late final OwnerAcademicController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerAcademicController>();
  }

  static const _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_academic_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        if (controller.resultCount == 0) return [_empty()];
        return [
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_ac_avg',
                value: controller.avgScore.toStringAsFixed(1),
                unitKey: 'owner_report_ac_of5',
                color: _blue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_ac_results', controller.resultCount)),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_ac_success',
                value: '${controller.successRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_ac_excellence',
                value: '${controller.excellenceRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFFF59E0B),
              ),
            ),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_ac_grade_mix',
            color: _blue,
          ),
          for (final s in controller.gradeDistribution)
            AnalyticsBarRow(
              label: s.grade.labelKey.tr,
              trailing: '${s.count}',
              fill: s.share,
              color: _gradeColor(s.grade),
            ),
          SizedBox(height: 6.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_ac_by_subject',
            color: _blue,
          ),
          for (final s in controller.subjectScores)
            AnalyticsBarRow(
              label: s.subject,
              trailing: s.avg.toStringAsFixed(1),
              fill: s.avg / 5,
              color: _blue,
              subtitle: 'owner_report_ac_subject_count'
                  .trParams({'n': '${s.count}'}),
            ),
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
            'owner_report_ac_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _gradeColor(ExamGrade g) {
    switch (g) {
      case ExamGrade.excellent:
        return const Color(0xFF16A34A);
      case ExamGrade.veryGood:
        return const Color(0xFF0891B2);
      case ExamGrade.good:
        return const Color(0xFF2563EB);
      case ExamGrade.acceptable:
        return const Color(0xFFF59E0B);
      case ExamGrade.needsImprovement:
        return const Color(0xFFEF4444);
    }
  }
}
