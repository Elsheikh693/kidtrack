import '../../../../../index/index_main.dart';
import 'activity_photo_thumb.dart';

class ActivityPhotosSection extends StatelessWidget {
  const ActivityPhotosSection({
    super.key,
    required this.photos,
    required this.children,
    required this.onAdd,
    required this.onDelete,
    required this.onSetAudience,
    this.isUploading = false,
  });

  final Map<String, ActivityPhoto> photos;
  final List<ChildModel> children;
  final VoidCallback onAdd;
  final void Function(String photoId) onDelete;
  final void Function(String photoId, List<String> childIds) onSetAudience;
  final bool isUploading;

  static const _cyanColor = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    final hasContent = photos.isNotEmpty || isUploading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cyanColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      size: 16, color: _cyanColor),
                ),
                const SizedBox(width: 10),
                Text(
                  'teacher_activity_photos_title'.tr,
                  style: context.typography.displaySmBold
                      .copyWith(color: AppColors.textDisplay),
                ),
                const Spacer(),
                if (photos.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: _cyanColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${photos.length}',
                      style: context.typography.xsMedium
                          .copyWith(color: _cyanColor),
                    ),
                  ),
              ],
            ),
          ),
          if (!hasContent)
            GestureDetector(
              onTap: onAdd,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _cyanColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _cyanColor.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined,
                          size: 32, color: _cyanColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'teacher_activity_photos_empty'.tr,
                      style: context.typography.displaySmBold
                          .copyWith(color: AppColors.textDisplay),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'teacher_activity_photos_empty_sub'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final cellSize =
                      (constraints.maxWidth - spacing * 2) / 3;
                  Widget cell(Widget child) =>
                      SizedBox(width: cellSize, height: cellSize, child: child);

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      cell(_AddMoreThumb(onTap: onAdd)),
                      if (isUploading) cell(_UploadingThumb()),
                      ...photos.entries.map(
                        (e) => cell(ActivityPhotoThumb(
                          photo: e.value,
                          children: children,
                          onDelete: onDelete,
                          onSetAudience: onSetAudience,
                        )),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AddMoreThumb extends StatelessWidget {
  const _AddMoreThumb({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0891B2).withValues(alpha: 0.06),
          border: Border.all(
            color: const Color(0xFF0891B2).withValues(alpha: 0.2),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Color(0xFF0891B2), size: 28),
          ],
        ),
      ),
    );
  }
}

class _UploadingThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0891B2).withValues(alpha: 0.06),
        border: Border.all(color: const Color(0xFF0891B2).withValues(alpha: 0.2)),
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
              color: Color(0xFF0891B2), strokeWidth: 2.5),
        ),
      ),
    );
  }
}
