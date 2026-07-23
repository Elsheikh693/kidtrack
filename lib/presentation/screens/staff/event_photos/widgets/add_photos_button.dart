import '../../../../../index/index_main.dart';

/// Gradient "add photos" action for the staff event photos screen.
class AddPhotosButton extends StatelessWidget {
  const AddPhotosButton({super.key, required this.controller});

  final EventPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.isUploading.value;
      return GestureDetector(
        onTap: busy ? null : controller.uploadPhotos,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.75),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_rounded,
                  color: AppColors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'event_photos_add'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      );
    });
  }
}
