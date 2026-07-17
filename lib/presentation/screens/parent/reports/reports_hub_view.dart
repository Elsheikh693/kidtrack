import '../../../../index/index_main.dart';
import 'widgets/report_hero_card.dart';
import 'widgets/report_grid_tile.dart';

/// Parent-facing Reports hub tab. A featured hero card for the live weekly
/// report sits above a 2×2 grid of colour-owned report tiles. Each entry
/// navigates to its own screen.
class ReportsHubView extends StatelessWidget {
  const ReportsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final activeChild = Get.find<ActiveChildService>();
    return Container(
      color: const Color(0xFFF6F5FB),
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
              padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reports_hub_title'.tr,
                    style: context.typography.xlBold
                        .copyWith(color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4.h),
                  Obx(() {
                    final name = activeChild.childName.value;
                    return Text(
                      name.isEmpty
                          ? 'reports_hub_tagline'.tr
                          : 'reports_hub_subtitle'.trParams({'name': name}),
                      style: context.typography.smRegular
                          .copyWith(color: const Color(0xFF64748B)),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  ReportHeroCard(
                    index: 0,
                    labelKey: 'report_attendance_title',
                    descKey: 'report_attendance_desc',
                    badgeKey: 'reports_featured_badge',
                    icon: Icons.event_available_rounded,
                    color: AppColors.primary,
                    onTap: () => Get.toNamed(weeklyAttendanceReportView),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ReportGridTile(
                          index: 1,
                          labelKey: 'report_learning_title',
                          descKey: 'report_learning_desc',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.activityBlue,
                          onTap: () => Get.toNamed(weeklyLearningReportView),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ReportGridTile(
                          index: 2,
                          labelKey: 'report_evaluation_title',
                          descKey: 'report_evaluation_desc',
                          icon: Icons.star_rounded,
                          color: AppColors.activityAmberBrand,
                          onTap: () => Get.toNamed(weeklyEvaluationReportView),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ReportGridTile(
                          index: 3,
                          labelKey: 'report_monthly_title',
                          descKey: 'report_monthly_desc',
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.activityPurple,
                          onTap: () => Get.toNamed(monthlyReportView),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: ReportGridTile(
                          index: 4,
                          labelKey: 'report_financial_title',
                          descKey: 'report_financial_desc',
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.activityGreen,
                          onTap: () => Get.toNamed(financialReportView),
                        ),
                      ),
                    ],
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
