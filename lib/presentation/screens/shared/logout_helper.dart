import '../../../index/index_main.dart';

/// Shows a styled confirmation dialog, then performs a full logout:
/// Firebase Auth sign-out + session clear + cached services wiped.
Future<void> showLogoutConfirm() async {
  final confirmed = await Get.dialog<bool>(
    const _LogoutConfirmDialog(),
    barrierDismissible: true,
  );
  if (confirmed == true) {
    await performLogout();
  }
}

/// Tears down the authenticated session and routes back to login.
///
/// Clears ALL local storage (session, cached metrics, active-child state, …)
/// while preserving UI-only preferences (language + theme), then signs out of
/// Firebase Auth and returns to the login screen.
Future<void> performLogout() async {
  Loader.show();
  try {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Auth instance may already be signed out — ignore.
    }

    if (Get.isRegistered<ActiveChildService>()) {
      await Get.find<ActiveChildService>().clearOnLogout();
    }

    await SessionService().clear();
    await StorageService().clearAll(
      preserve: const {'lang', 'themeMode', Strings.hasSeenOnboard},
      preservePrefixes: const {
        SetupLocalCheck.keyPrefix,
        NurseryFeedbackGate.keyPrefix,
      },
    );
  } finally {
    Loader.dismiss();
  }
  Get.offAllNamed(nurseryDiscoveryView);
}

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.errorForeground,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'logout_confirm_title'.tr,
                style: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 8.h),
              Text(
                'logout_confirm_message'.tr,
                textAlign: TextAlign.center,
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: BorderSide(
                          color: AppColors.borderNeutralPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'common_cancel'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorForeground,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'logout_confirm_button'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
