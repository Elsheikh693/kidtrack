import '../../../../../index/index_main.dart';
import '../../children/widgets/overview_kpi_card.dart';

/// Top-of-tab snapshot: total active staff, who is present today, who is on
/// leave, and how many classrooms are missing a teacher.
class StaffOverviewSection extends StatelessWidget {
  const StaffOverviewSection({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Obx(
          () => Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_staff_kpi_total'.tr,
                  value: '${controller.totalStaff.value}',
                  icon: Icons.badge_rounded,
                  color: AppColors.activityBlue,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_staff_kpi_present'.tr,
                  value: '${controller.presentToday.value}',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.activityGreen,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_staff_kpi_leave'.tr,
                  value: '${controller.onLeaveToday.value}',
                  icon: Icons.beach_access_rounded,
                  color: AppColors.activityPurple,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: OverviewKpiCard(
                  label: 'manager_staff_kpi_gaps'.tr,
                  value: '${controller.coverageGapCount.value}',
                  icon: Icons.report_gmailerrorred_rounded,
                  color: AppColors.activityAmberBrand,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
