import '../../../../index/index_main.dart';

class NotifSettingsHeader extends StatelessWidget {
  const NotifSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 18.sp),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 18.h),
        title: Text(
          'notif_settings_title'.tr,
          style: context.typography.mdBold.copyWith(color: AppColors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary80],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -25,
              left: -10,
              child: Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.22),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.notifications_rounded, color: AppColors.white, size: 42.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
