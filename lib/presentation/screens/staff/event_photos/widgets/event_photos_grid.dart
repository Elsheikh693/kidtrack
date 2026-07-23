import '../../../../../index/index_main.dart';
import 'event_photo_tile.dart';
import 'event_photos_empty.dart';

/// Grid of all event photos (approved + pending) with an uploading placeholder.
class EventPhotosGrid extends StatelessWidget {
  const EventPhotosGrid({super.key, required this.controller});

  final EventPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photos = controller.photos;
      final uploading = controller.isUploading.value;
      if (photos.isEmpty && !uploading) {
        return const EventPhotosEmpty();
      }
      final itemCount = photos.length + (uploading ? 1 : 0);
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 96.h),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: itemCount,
        itemBuilder: (_, i) {
          if (uploading && i == 0) return const _UploadingTile();
          final photo = photos[uploading ? i - 1 : i];
          return EventPhotoTile(
            photo: photo,
            onDelete: photo.isApproved
                ? null
                : () => _confirmDelete(context, photo.id),
          );
        },
      );
    });
  }

  void _confirmDelete(BuildContext context, String photoId) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text('event_photos_delete_title'.tr),
        content: Text('event_photos_delete_body'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('common_cancel'.tr,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.grayMedium)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removePhoto(photoId);
            },
            child: Text('common_delete'.tr,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.errorForeground)),
          ),
        ],
      ),
    );
  }
}

class _UploadingTile extends StatelessWidget {
  const _UploadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
