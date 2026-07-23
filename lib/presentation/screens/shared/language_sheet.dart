import '../../../index/index_main.dart';

void showLanguageSheet() {
  Get.bottomSheet(
    const _LanguageSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<AppLanguage>();
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'settings_language_sheet_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() => _LangTile(
              label: 'settings_lang_ar'.tr,
              flag: '🇸🇦',
              isSelected: lang.appLocale.value == 'ar',
              onTap: () async {
                await lang.changeLanguage('ar');
                Get.back();
                Loader.showSuccess('settings_lang_changed'.tr);
              },
            )),
            SizedBox(height: 10.h),
            Obx(() => _LangTile(
              label: 'settings_lang_en'.tr,
              flag: '🇬🇧',
              isSelected: lang.appLocale.value == 'en',
              onTap: () async {
                await lang.changeLanguage('en');
                Get.back();
                Loader.showSuccess('settings_lang_changed'.tr);
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: context.typography.mdRegular.copyWith(fontSize: 22)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: context.typography.smMedium.copyWith(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
