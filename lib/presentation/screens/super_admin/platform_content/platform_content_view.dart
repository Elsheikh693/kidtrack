import '../../../../index/index_main.dart';

/// Super admin hub for managing the pre-login platform content:
/// contact info, about us, and incoming support requests.
class PlatformContentView extends StatelessWidget {
  const PlatformContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textDefault, size: 20.sp),
        ),
        title: Text(
          'pcontent_title'.tr,
          style:
              context.typography.mdBold.copyWith(color: AppColors.textDefault),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
        children: [
          _Tile(
            icon: Icons.support_agent_rounded,
            color: const Color(0xFF6366F1),
            title: 'pcontent_contact'.tr,
            subtitle: 'pcontent_contact_sub'.tr,
            onTap: () => Get.toNamed(contactInfoFormView),
          ),
          SizedBox(height: 12.h),
          _Tile(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF0EA5E9),
            title: 'pcontent_about'.tr,
            subtitle: 'pcontent_about_sub'.tr,
            onTap: () => Get.toNamed(aboutUsFormView),
          ),
          SizedBox(height: 12.h),
          _Tile(
            icon: Icons.inbox_rounded,
            color: const Color(0xFFF59E0B),
            title: 'pcontent_support'.tr,
            subtitle: 'pcontent_support_sub'.tr,
            onTap: () => Get.toNamed(supportRequestsAdminView),
          ),
          SizedBox(height: 12.h),
          _Tile(
            icon: Icons.reviews_rounded,
            color: const Color(0xFFEC4899),
            title: 'pcontent_reviews'.tr,
            subtitle: 'pcontent_reviews_sub'.tr,
            onTap: () => Get.toNamed(appReviewsAdminView),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayLight.withValues(alpha: 0.6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(icon, size: 23.sp, color: color),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 22.sp, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}
