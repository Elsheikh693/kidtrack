import '../../../../index/index_main.dart';

/// Congratulates the user the moment they finish the final tutorial step.
void showTutorialCompleteDialog() {
  Get.dialog(
    Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(Animations.success,
                  width: 120.w, height: 120.w, repeat: false),
              SizedBox(height: 8.h),
              AppText(
                text: 'tutorial_done_title'.tr,
                textStyle: Get.context!.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              AppText(
                text: 'tutorial_done_msg'.tr,
                textStyle: Get.context!.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: AppText(
                    text: 'tutorial_done_cta'.tr,
                    textStyle: Get.context!.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
