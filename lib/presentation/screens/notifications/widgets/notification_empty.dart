import '../../../../index/index_main.dart';

class NotificationEmpty extends StatelessWidget {
  const NotificationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.notifications_rounded, size: 40.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            text: 'notif_empty_title'.tr,
            textStyle: context.typography.lgBold.copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 8.h),
          AppText(
            text: 'notif_empty_subtitle'.tr,
            textStyle: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
