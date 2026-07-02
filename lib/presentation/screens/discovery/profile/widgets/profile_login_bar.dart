import '../../../../../index/index_main.dart';

class ProfileLoginBar extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onApply;
  const ProfileLoginBar({
    super.key,
    required this.onLogin,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, 14.h, 20.w, 14.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary80.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryTextButton(
              appButtonSize: AppButtonSize.xlarge,
              onTap: onApply,
              leading: (c) =>
                  Icon(Icons.app_registration_rounded, size: 20.sp, color: c),
              label: AppText(
                text: 'apply_online_btn'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onLogin,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AppText(
                    text: 'discovery_login_btn'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.primary),
                  ),
                  SizedBox(width: 6.w),
                  Transform.flip(
                    flipX: true,
                    child: Icon(Icons.login_rounded,
                        size: 20.sp, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
