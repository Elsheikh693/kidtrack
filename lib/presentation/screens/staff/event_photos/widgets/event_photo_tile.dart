import '../../../../../index/index_main.dart';
import '../../../manager/media_approval/widgets/full_photo_view.dart';

/// One event photo in the staff grid. Pending (not-yet-approved) photos carry a
/// small clock badge; a delete handle (long-press) is offered when [onDelete]
/// is provided (pending photos only).
class EventPhotoTile extends StatelessWidget {
  const EventPhotoTile({
    super.key,
    required this.photo,
    this.onDelete,
  });

  final ActivityPhoto photo;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FullPhotoView.show(context, photo.url),
      onLongPress: onDelete,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: appCachedImageProvider(photo.url),
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(color: const Color(0xFFEDEFF3)),
              errorBuilder: (_, e, s) => Container(
                color: const Color(0xFFEDEFF3),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: AppColors.grayMedium, size: 22),
                ),
              ),
            ),
            if (!photo.isApproved)
              PositionedDirectional(
                top: 6,
                start: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          color: Colors.white, size: 11),
                      SizedBox(width: 3.w),
                      Text(
                        'event_photos_pending'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: Colors.white, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
              ),
            if (onDelete != null)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
