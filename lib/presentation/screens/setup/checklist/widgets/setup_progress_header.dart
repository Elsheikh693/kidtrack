import '../../../../../index/index_main.dart';

class SetupHubProgressHeader extends StatelessWidget {
  final SetupChecklistController controller;
  const SetupHubProgressHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final done = controller.doneCount;
      final total = controller.totalCount;
      final percent = (controller.progress * 100).round();
      final complete = controller.allDone;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary80],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    complete
                        ? Icons.verified_rounded
                        : Icons.rocket_launch_rounded,
                    color: AppColors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'setup_hub_title'.tr,
                        style: context.typography.lgBold
                            .copyWith(color: AppColors.white),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'setup_hub_subtitle'.tr,
                        style: context.typography.smRegular.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 8.h,
                      backgroundColor: AppColors.white.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '$percent%',
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'setup_hub_progress'
                  .trParams({'done': '$done', 'total': '$total'}),
              style: context.typography.xsMedium.copyWith(color: AppColors.white),
            ),
          ],
        ),
      );
    });
  }
}
