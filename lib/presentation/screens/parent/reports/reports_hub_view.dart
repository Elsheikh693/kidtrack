import '../../../../index/index_main.dart';
import 'widgets/report_hero_card.dart';
import 'widgets/report_list_row.dart';
import 'widgets/report_section_header.dart';

/// Parent-facing Reports hub tab. A clear three-part hierarchy: a featured
/// monthly overview, the week's reports, then finance — each entry navigating
/// to its own screen.
class ReportsHubView extends StatelessWidget {
  const ReportsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentTabScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          ReportHeroCard(
            index: 0,
            labelKey: 'report_monthly_title',
            descKey: 'report_monthly_desc',
            badgeKey: 'reports_monthly_badge',
            icon: Icons.calendar_month_rounded,
            color: AppColors.activityPurple,
            onTap: () => Get.toNamed(monthlyReportView),
          ),
          ReportSectionHeader(
            titleKey: 'reports_section_weekly',
            color: AppColors.primary,
          ),
          ReportListRow(
            index: 1,
            labelKey: 'report_attendance_title',
            descKey: 'report_attendance_desc',
            icon: Icons.event_available_rounded,
            color: AppColors.primary,
            onTap: () => Get.toNamed(weeklyAttendanceReportView),
          ),
          SizedBox(height: 12.h),
          ReportListRow(
            index: 2,
            labelKey: 'report_learning_title',
            descKey: 'report_learning_desc',
            icon: Icons.menu_book_rounded,
            color: AppColors.activityBlue,
            onTap: () => Get.toNamed(weeklyLearningReportView),
          ),
          SizedBox(height: 12.h),
          ReportListRow(
            index: 3,
            labelKey: 'report_evaluation_title',
            descKey: 'report_evaluation_desc',
            icon: Icons.star_rounded,
            color: AppColors.activityAmberBrand,
            onTap: () => Get.toNamed(weeklyEvaluationReportView),
          ),
          SizedBox(height: 12.h),
          ReportListRow(
            index: 4,
            labelKey: 'assessment_parent_title',
            descKey: 'assessment_parent_report_desc',
            icon: Icons.assignment_turned_in_rounded,
            color: const Color(0xFF4F46E5),
            onTap: () => Get.toNamed(parentAssessmentsView),
          ),
          const ReportSectionHeader(
            titleKey: 'reports_section_finance',
            color: AppColors.activityGreen,
          ),
          ReportListRow(
            index: 5,
            labelKey: 'report_financial_title',
            descKey: 'report_financial_desc',
            icon: Icons.receipt_long_rounded,
            color: AppColors.activityGreen,
            onTap: () => Get.toNamed(financialReportView),
          ),
        ],
      ),
    );
  }
}
