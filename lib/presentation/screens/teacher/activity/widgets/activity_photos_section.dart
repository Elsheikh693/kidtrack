import '../../../../../index/index_main.dart';

class ActivityPhotosSection extends StatelessWidget {
  const ActivityPhotosSection({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onDelete,
    this.isUploading = false,
  });

  final Map<String, String> photos;
  final VoidCallback onAdd;
  final void Function(String photoId) onDelete;
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
                        (e) => cell(_PhotoThumb(
                          photoId: e.key,
                          url: e.value,
                          onDelete: onDelete,
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

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({
    required this.photoId,
    required this.url,
    required this.onDelete,
  });

  final String photoId;
  final String url;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              image: appCachedImageProvider(url),
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null
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
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
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
    if (confirmed == true) onDelete(photoId);
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
