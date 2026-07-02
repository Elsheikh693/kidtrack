import '../../../../index/index_main.dart';

class NotifSettingsBanner extends StatelessWidget {
  const NotifSettingsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary80],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded, color: AppColors.white, size: 26.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'notif_settings_banner_title'.tr,
                  style: context.typography.smSemiBold.copyWith(color: AppColors.white),
                ),
                SizedBox(height: 6.h),
                Text(
                  'notif_settings_banner_body'.tr,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
