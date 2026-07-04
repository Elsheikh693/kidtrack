import '../../../../../index/index_main.dart';

class ProfileLoginBar extends StatelessWidget {
  final VoidCallback onLogin;
  const ProfileLoginBar({
    super.key,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    // Online application is disabled for now — the bar exposes only the login
    // action, stretched full-width.
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
      child: GestureDetector(
        onTap: onLogin,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
    );
  }
}
