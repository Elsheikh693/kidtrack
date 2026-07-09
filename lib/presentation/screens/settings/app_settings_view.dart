import 'dart:io';

import '../../../index/index_main.dart';

/// Pre-login settings hub reached from the Discovery screen's settings icon.
class AppSettingsView extends StatelessWidget {
  const AppSettingsView({super.key});

  Future<void> _openStore() async {
    final url = Platform.isIOS ? Strings.urlIos : Strings.urlAndroid;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('contact_launch_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.textDefault, size: 22.sp),
          ),
          title: AppText(
            text: 'settings_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
          children: [
            _SettingsTile(
              icon: Icons.call_rounded,
              iconColor: const Color(0xFF6366F1),
              title: 'settings_contact_us'.tr,
              subtitle: 'settings_contact_us_sub'.tr,
              onTap: () => Get.toNamed(contactUsView),
            ),
            SizedBox(height: 14.h),
            _SettingsTile(
              icon: Icons.business_rounded,
              iconColor: const Color(0xFF0EA5E9),
              title: 'settings_about_us'.tr,
              subtitle: 'settings_about_us_sub'.tr,
              onTap: () => Get.toNamed(aboutUsView),
            ),
            SizedBox(height: 14.h),
            _SettingsTile(
              icon: Icons.headset_mic_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'settings_support'.tr,
              subtitle: 'settings_support_sub'.tr,
              onTap: () => Get.toNamed(supportRequestView),
            ),
            SizedBox(height: 14.h),
            _SettingsTile(
              icon: Icons.handshake_rounded,
              iconColor: const Color(0xFF10B981),
              title: 'settings_join'.tr,
              subtitle: 'settings_join_sub'.tr,
              onTap: () => Get.toNamed(joinUsView),
            ),
            SizedBox(height: 14.h),
            _SettingsTile(
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFEC4899),
              title: 'settings_review'.tr,
              subtitle: 'settings_review_sub'.tr,
              onTap: () => Get.toNamed(appReviewView),
            ),
            SizedBox(height: 14.h),
            _SettingsTile(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: 'settings_rate_store'.tr,
              subtitle: 'settings_rate_store_sub'.tr,
              onTap: _openStore,
            ),
            if (!SessionService().isLoggedIn) ...[
              SizedBox(height: 14.h),
              _SettingsTile(
                icon: Icons.login_rounded,
                iconColor: AppColors.primary,
                title: 'settings_login'.tr,
                subtitle: 'settings_login_sub'.tr,
                onTap: openActivationLoginSheet,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(icon, size: 24.sp, color: iconColor),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: title,
                      textStyle: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      text: subtitle,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 20.sp, color: AppColors.grayMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
