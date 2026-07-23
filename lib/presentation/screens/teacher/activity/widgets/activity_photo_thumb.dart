import '../../../../../index/index_main.dart';
import 'photo_audience_sheet.dart';

/// A single uploaded activity photo in the teacher's grid. Shows an audience
/// badge (classroom-wide 🌍 or private 👤N) in the corner; tapping opens the
/// "Send To" picker, long-pressing deletes.
class ActivityPhotoThumb extends StatelessWidget {
  const ActivityPhotoThumb({
    super.key,
    required this.photo,
    required this.children,
    required this.onDelete,
    required this.onSetAudience,
  });

  final ActivityPhoto photo;
  final List<ChildModel> children;
  final void Function(String photoId) onDelete;
  final void Function(String photoId, List<String> childIds) onSetAudience;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAudience(context),
      onLongPress: () => _confirmDelete(context),
      child: Container(
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
                child: Icon(Icons.broken_image_rounded,
                    color: Colors.grey, size: 28),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 6,
              start: 6,
              child: _AudienceBadge(photo: photo),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAudience(BuildContext context) async {
    final result = await PhotoAudienceSheet.show(
      context,
      children: children,
      initialSelection: photo.targetChildren,
    );
    if (result != null) onSetAudience(photo.id, result);
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => Directionality(
        textDirection: appTextDirection,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'teacher_activity_delete_photo'.tr,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(
                'teacher_activity_delete_cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(c, true),
              child: Text('teacher_activity_delete_confirm'.tr),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) onDelete(photo.id);
  }
}

class _AudienceBadge extends StatelessWidget {
  const _AudienceBadge({required this.photo});

  final ActivityPhoto photo;

  @override
  Widget build(BuildContext context) {
    final isPrivate = !photo.isClassroomWide;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isPrivate ? 7 : 5, vertical: 4),
      decoration: BoxDecoration(
        color: (isPrivate ? const Color(0xFF7C3AED) : Colors.black)
            .withValues(alpha: 0.6),
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
