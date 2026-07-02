import '../../../../../index/index_main.dart';

/// Owner-controlled "show this nursery in Discovery" switch. Enabled only when
/// the profile meets the readiness bar (name + cover + location); otherwise it
/// stays off and lists what is still missing so the owner knows what to fill.
class ProfileVisibilityToggle extends StatelessWidget {
  const ProfileVisibilityToggle({super.key, required this.controller});
  final ManagerNurseryProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final listed = controller.isListed.value;
      final ready = controller.canList;
      final missing = controller.missingForListing;
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: listed
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  listed
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: 20.sp,
                  color: listed ? AppColors.primary : AppColors.grayMedium,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppText(
                    text: 'manager_profile_list_toggle'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.textPrimaryParagraph),
                  ),
                ),
                Switch(
                  value: listed,
                  activeThumbColor: AppColors.primary,
                  onChanged: controller.setListed,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            AppText(
              text: 'manager_profile_list_hint'.tr,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.grayMedium),
            ),
            if (!ready && missing.isNotEmpty) ...[
              SizedBox(height: 12.h),
              AppText(
                text: 'manager_profile_list_incomplete'.tr,
                textStyle: context.typography.xsMedium
                    .copyWith(color: AppColors.errorForeground),
              ),
              SizedBox(height: 6.h),
              for (final key in missing)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 14.sp, color: AppColors.errorForeground),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          text: key.tr,
                          textStyle: context.typography.xsRegular
                              .copyWith(color: AppColors.textPrimaryParagraph),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }
}
