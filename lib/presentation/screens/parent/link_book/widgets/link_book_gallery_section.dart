import 'package:flutter/material.dart';
import '../../../../../Global/widgets/app_network_image.dart';
import '../../education/widgets/journal_meta.dart';
import '../link_book_controller.dart';
import 'photo_gallery_viewer.dart';

/// "ألبوم اليوم" — a polished mosaic of the day's photos that opens the
/// immersive full-screen viewer with a Hero transition.
class LinkBookGallerySection extends StatelessWidget {
  const LinkBookGallerySection({super.key, required this.photos});

  final List<LinkBookPhoto> photos;

  static const _accent = Color(0xFF0EA5E9);
  static const _maxThumbs = 6;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    final shown = photos.take(_maxThumbs).toList();
    final overflow = photos.length - shown.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kJBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    size: 17, color: _accent),
              ),
              const SizedBox(width: 10),
              const Text(
                'ألبوم اليوم',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kJInk,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${photos.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              const spacing = 8.0;
              final tile = (c.maxWidth - spacing * 2) / 3;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < shown.length; i++)
                    _Thumb(
                      photo: shown[i],
                      index: i,
                      size: tile,
                      overflow:
                          (i == shown.length - 1 && overflow > 0) ? overflow : 0,
                      onTap: () => openPhotoGallery(
                        context,
                        photos: photos,
                        initialIndex: i,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.index,
    required this.size,
    required this.overflow,
    required this.onTap,
  });

  final LinkBookPhoto photo;
  final int index;
  final double size;
  final int overflow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'lbphoto_${photo.url}',
                child: Image(
                  image: appCachedImageProvider(photo.url),
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, st) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(Icons.image_not_supported_rounded,
                        color: Colors.grey.shade400),
                  ),
                ),
              ),
              if (overflow > 0)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  alignment: Alignment.center,
                  child: Text(
                    '+$overflow',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
