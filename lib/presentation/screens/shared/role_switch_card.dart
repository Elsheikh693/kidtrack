import '../../../index/index_main.dart';

/// "Switch role" entry point for a multi-hat identity. Renders nothing unless the
/// current identity holds more than one membership, so it can be dropped safely
/// into any account / "more" tab. Tapping opens the login role picker in switch
/// mode ([openRoleSwitcher]).
class RoleSwitchCard extends StatelessWidget {
  const RoleSwitchCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SessionService().hasMultipleRoles) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: openRoleSwitcher,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'role_switch_title'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      text: 'role_switch_subtitle'.tr,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
