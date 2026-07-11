import '../../../../index/index_main.dart';
import 'widgets/report_entry_card.dart';

/// Parent-facing Reports hub tab. Uses the shared [ParentTopBar] like the other
/// parent tabs, then a staggered list of report entries. Only Weekly Attendance
/// is live in v1; the rest navigate to their own screens.
class ReportsHubView extends StatelessWidget {
  const ReportsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final activeChild = Get.find<ActiveChildService>();
    return Container(
      color: const Color(0xFFF4F4F8),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(bottom: 110.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ParentTopBar(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reports_hub_title'.tr,
                    style: context.typography.xlBold.copyWith(
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Obx(() {
                    final name = activeChild.childName.value;
                    return Text(
                      name.isEmpty
                          ? 'reports_hub_tagline'.tr
                          : 'reports_hub_subtitle'.trParams({'name': name}),
                      style: context.typography.smRegular.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  ReportEntryCard(
                    index: 0,
                    labelKey: 'report_attendance_title',
                    descKey: 'report_attendance_desc',
                    icon: Icons.event_available_rounded,
                    color: AppColors.primary,
                    onTap: () => Get.toNamed(weeklyAttendanceReportView),
                  ),
                  ReportEntryCard(
                    index: 1,
                    labelKey: 'report_learning_title',
                    descKey: 'report_learning_desc',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF0891B2),
                    onTap: () => Get.toNamed(weeklyLearningReportView),
                  ),
                  ReportEntryCard(
                    index: 2,
                    labelKey: 'report_evaluation_title',
                    descKey: 'report_evaluation_desc',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => Get.toNamed(weeklyEvaluationReportView),
                  ),
                  ReportEntryCard(
                    index: 3,
                    labelKey: 'report_monthly_title',
                    descKey: 'report_monthly_desc',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => Get.toNamed(monthlyReportView),
                  ),
                  ReportEntryCard(
                    index: 4,
                    labelKey: 'report_financial_title',
                    descKey: 'report_financial_desc',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () => Get.toNamed(financialReportView),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
