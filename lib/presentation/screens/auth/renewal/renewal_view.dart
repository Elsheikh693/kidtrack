import '../../../../index/index_main.dart';

/// Shown to an owner whose nursery subscription is suspended
/// (`platform/{nurseryId}/info/isActive == false`). Everyone else in a
/// suspended nursery is sent back to login instead.
class RenewalView extends StatelessWidget {
  const RenewalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96.w,
                  height: 96.h,
                  decoration: BoxDecoration(
                    color: AppColors.errorForeground.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    size: 48.sp,
                    color: AppColors.errorForeground,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'renewal_title'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.xlBold.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'renewal_message'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular.copyWith(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
                SizedBox(height: 36.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(supportRequestView),
                    icon: const Icon(Icons.support_agent_rounded),
                    label: Text('renewal_contact_btn'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: performLogout,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      foregroundColor: AppColors.textSecondaryParagraph,
                      side: BorderSide(color: AppColors.borderNeutralPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text('renewal_logout_btn'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
