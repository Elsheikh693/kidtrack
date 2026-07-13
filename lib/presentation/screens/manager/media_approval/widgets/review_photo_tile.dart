import '../../../../../index/index_main.dart';
import '../../../teacher/activity/widgets/photo_audience_sheet.dart';

/// A pending photo in the reviewer's grid. Tap the audience badge to change who
/// it is for; tap ✕ to reject (delete) it.
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
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: appCachedImageProvider(photo.url),
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(color: Colors.grey.shade200),
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
          ),
          PositionedDirectional(
            top: 6,
            start: 6,
            child: GestureDetector(
              onTap: () => _openAudience(context),
              child: _AudienceBadge(photo: photo),
            ),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: GestureDetector(
              onTap: onReject,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
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

class _AudienceBadge extends StatelessWidget {
  const _AudienceBadge({required this.photo});

  final ActivityPhoto photo;

  @override
  Widget build(BuildContext context) {
    final isPrivate = !photo.isClassroomWide;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isPrivate ? 7 : 5, vertical: 4),
      decoration: BoxDecoration(
        color: (isPrivate ? const Color(0xFF7C3AED) : Colors.black).withValues(
          alpha: 0.6,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.person_rounded : Icons.groups_rounded,
            color: Colors.white,
            size: 13,
          ),
          if (isPrivate && photo.targetChildren.length > 1) ...[
            const SizedBox(width: 3),
            Text(
              '${photo.targetChildren.length}',
              style: context.typography.xsBold.copyWith(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
