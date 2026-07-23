import '../../../../index/index_main.dart';

class ApplySuccessView extends StatelessWidget {
  const ApplySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  width: 220.w,
                  height: 220.w,
                  child: Lottie.asset(
                    Animations.success,
                    repeat: false,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 8.h),
                AppText(
                  text: 'apply_success_title'.tr,
                  textStyle: context.typography.xlBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                AppText(
                  text: 'apply_success_sub'.tr,
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.7,
                  ),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.activityGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_rounded,
                          size: 20.sp, color: AppColors.activityGreen),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: AppText(
                          text: 'apply_success_whatsapp'.tr,
                          textStyle: context.typography.xsMedium.copyWith(
                            color: AppColors.activityGreen,
                            height: 1.6,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryTextButton(
                  appButtonSize: AppButtonSize.xlarge,
                  onTap: Get.back,
                  label: AppText(
                    text: 'apply_success_btn'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
