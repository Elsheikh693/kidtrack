import '../../../../../index/index_main.dart';

void showDiscoveryNotificationsSheet() {
  Get.bottomSheet(
    const _NotificationsSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            AppText(
              text: 'discovery_notifications_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 28.h),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded,
                        size: 40.sp, color: AppColors.primary40),
                  ),
                  SizedBox(height: 18.h),
                  AppText(
                    text: 'discovery_notifications_empty'.tr,
                    textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
