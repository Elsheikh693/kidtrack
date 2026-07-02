import '../../../../../index/index_main.dart';

class ProfileGalleryEditor extends StatelessWidget {
  const ProfileGalleryEditor({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.photos.length + 1,
          separatorBuilder: (context, index) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            if (index == 0) return _addTile(context);
            final url = controller.photos[index - 1];
            return _photoTile(url);
          },
        ),
      ),
    );
  }

  Widget _addTile(BuildContext context) {
    return GestureDetector(
      onTap: controller.addPhotos,
      child: Container(
        width: 110.w,
        height: 110.h,
        decoration: BoxDecoration(
          color: AppColors.primary10,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary60),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.primary, size: 28.r),
            SizedBox(height: 4.h),
            AppText(
              text: 'manager_profile_add_photo'.tr,
              textStyle:
                  context.typography.xsMedium.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoTile(String url) {
    return Stack(
      children: [
        AppNetworkImage(
          url: url,
          width: 140.w,
          height: 110.h,
          borderRadius: BorderRadius.circular(14.r),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => controller.removePhoto(url),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  color: AppColors.white, size: 16.r),
            ),
          ),
        ),
      ],
    );
  }
}
