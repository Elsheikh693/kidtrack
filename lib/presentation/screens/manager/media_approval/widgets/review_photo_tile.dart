import '../../../../../index/index_main.dart';
import '../../../teacher/activity/widgets/photo_audience_sheet.dart';
import 'full_photo_view.dart';

/// A pending photo in the reviewer's grid: the photo sits on top with a frosted
/// reject button, and a tappable audience selector bar runs underneath.
class ReviewPhotoTile extends StatelessWidget {
  const ReviewPhotoTile({
    super.key,
    required this.photo,
    required this.children,
    required this.onReject,
    required this.onSetAudience,
  });

  final ActivityPhoto photo;
  final List<ChildModel> children;
  final VoidCallback onReject;
  final void Function(List<String> childIds) onSetAudience;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => FullPhotoView.show(context, photo.url),
                  child: Image(
                    image: appCachedImageProvider(photo.url),
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(color: const Color(0xFFEDEFF3)),
                    errorBuilder: (_, e, s) => Container(
                      color: const Color(0xFFEDEFF3),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: AppColors.grayMedium, size: 26),
                      ),
                    ),
                  ),
                ),
                // Soft top scrim so the reject button reads on light photos.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: GestureDetector(
                    onTap: onReject,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _AudienceBar(
            photo: photo,
            onTap: () => _openAudience(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openAudience(BuildContext context) async {
    final result = await PhotoAudienceSheet.show(
      context,
      children: children,
      initialSelection: photo.targetChildren,
    );
    if (result != null) onSetAudience(result);
  }
}

class _AudienceBar extends StatelessWidget {
  const _AudienceBar({required this.photo, required this.onTap});

  final ActivityPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrivate = !photo.isClassroomWide;
    final color =
        isPrivate ? AppColors.activityPurple : AppColors.activityBlue;
    final label = isPrivate
        ? (photo.targetChildren.length > 1
            ? '${photo.targetChildren.length}'
            : 'media_audience_private'.tr)
        : 'media_audience_all'.tr;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F3F6))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPrivate ? Icons.person_rounded : Icons.groups_rounded,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: context.typography.xsMedium
                    .copyWith(color: AppColors.textDefault),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.unfold_more_rounded,
                color: AppColors.grayMedium, size: 15),
          ],
        ),
      ),
    );
  }
}
