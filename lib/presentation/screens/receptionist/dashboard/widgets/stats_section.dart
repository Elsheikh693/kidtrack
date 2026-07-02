import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'section_header.dart';

class DashboardStatsSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const DashboardStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return _StatsSkeleton();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(title: 'reception_stats_today'.tr),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_total'.tr,
                  value: controller.totalStudents.value,
                  icon: Icons.child_care_rounded,
                  colors: const [Color(0xFF16A34A), Color(0xFF15803D)],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_present'.tr,
                  value: controller.presentToday.value,
                  icon: Icons.login_rounded,
                  colors: const [Color(0xFF0891B2), Color(0xFF0E7490)],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_absent'.tr,
                  value: controller.absentToday.value,
                  icon: Icons.event_busy_rounded,
                  colors: const [Color(0xFFDC2626), Color(0xFFB91C1C)],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_inside'.tr,
                  value: controller.insideNow.value,
                  icon: Icons.home_work_rounded,
                  colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_checkout'.tr,
                  value: controller.checkedOutToday.value,
                  icon: Icons.logout_rounded,
                  colors: const [Color(0xFFF97316), Color(0xFFEA580C)],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GradientStatCard(
                  label: 'reception_stat_classes'.tr,
                  value: controller.totalClasses.value,
                  icon: Icons.class_rounded,
                  colors: const [Color(0xFFD97706), Color(0xFFB45309)],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _GradientStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> colors;

  const _GradientStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88.h,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.35),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: context.typography.xxlBold.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),
          _skeletonRow(),
          SizedBox(height: 10.h),
          _skeletonRow(),
        ],
      ),
    );
  }

  Widget _skeletonRow() => Row(
    children: [
      _skeletonCard(),
      SizedBox(width: 10.w),
      _skeletonCard(),
      SizedBox(width: 10.w),
      _skeletonCard(),
    ],
  );

  Widget _skeletonCard() => Expanded(
    child: Container(
      height: 88.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
  );
}
