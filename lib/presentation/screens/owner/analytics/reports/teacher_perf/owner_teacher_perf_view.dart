import '../../../../../../index/index_main.dart';
import '../../../../manager/teacher_reports/widgets/tr_summary_hero.dart';
import '../../../../manager/teacher_reports/widgets/tr_activity_chart.dart';
import '../../../../manager/teacher_reports/widgets/tr_teacher_card.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_section_header.dart';

/// Teacher Performance report — network-wide teacher activity over the last 30
/// days, reusing the manager's summary hero, activity chart and teacher cards.
class OwnerTeacherPerfView extends StatefulWidget {
  const OwnerTeacherPerfView({super.key});

  @override
  State<OwnerTeacherPerfView> createState() => _OwnerTeacherPerfViewState();
}

class _OwnerTeacherPerfViewState extends State<OwnerTeacherPerfView> {
  late final OwnerTeacherPerfController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerTeacherPerfController>();
  }

  static const _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_teacher_perf_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        final teachers = controller.teachers;
        if (teachers.isEmpty) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_tp_empty'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        return [
          Text(
            'owner_report_tp_window_note'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 12.h),
          TrSummaryHero(summary: controller.summary.value, accent: _accent),
          SizedBox(height: 14.h),
          TrActivityChart(teachers: teachers, accent: _accent),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_tp_teachers',
            color: _accent,
          ),
          for (final t in teachers)
            TrTeacherCard(
              data: t,
              accent: _accent,
              showSparkline: true,
              onTap: () {},
            ),
        ];
      },
    );
  }
}
