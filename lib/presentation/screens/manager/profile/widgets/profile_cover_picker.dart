import '../../../../../index/index_main.dart';

class ProfileCoverPicker extends StatelessWidget {
  const ProfileCoverPicker({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: controller.pickCover,
            child: Obx(
              () => Container(
                width: double.infinity,
                height: 170.h,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: controller.coverPhoto.value != null
                    ? AppNetworkImage(
                        url: controller.coverPhoto.value,
                        width: double.infinity,
                        height: 170.h,
                      )
                    : _placeholder(
                        context,
                        Icons.add_photo_alternate_rounded,
                        'manager_profile_cover_hint'.tr,
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 34.h,
            right: 116.w,
            left: 16.w,
            child: AppText(
              text: 'manager_profile_logo_hint'.tr,
              textStyle: context.typography.xsMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 16.w,
            child: GestureDetector(
              onTap: controller.pickLogo,
              child: Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Obx(
                  () => controller.logo.value != null
                      ? AppNetworkImage(
                          url: controller.logo.value,
                          width: 88.w,
                          height: 88.w,
                        )
                      : Icon(Icons.add_a_photo_rounded,
                          color: AppColors.primary, size: 28.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 36.r),
        SizedBox(height: 8.h),
        AppText(
          text: label,
          textStyle: context.typography.xsMedium
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
      ],
    );
  }
}
