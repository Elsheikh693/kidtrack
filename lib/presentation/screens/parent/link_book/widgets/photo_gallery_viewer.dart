import 'package:flutter/material.dart';
import '../../../../../Global/widgets/app_network_image.dart';
import '../../education/widgets/journal_meta.dart';
import '../link_book_controller.dart';
import '../../../../../Global/Localization/app_direction.dart';

/// Immersive full-screen photo viewer: swipe between the day's photos,
/// pinch-to-zoom each one, with a Hero transition in from the album thumbnail.
void openPhotoGallery(
  BuildContext context, {
  required List<LinkBookPhoto> photos,
  required int initialIndex,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) =>
          _PhotoGalleryViewer(photos: photos, initialIndex: initialIndex),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class _PhotoGalleryViewer extends StatefulWidget {
  const _PhotoGalleryViewer({required this.photos, required this.initialIndex});
  final List<LinkBookPhoto> photos;
  final int initialIndex;

  @override
  State<_PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<_PhotoGalleryViewer> {
  late final PageController _page;
  late int _index;
  bool _chrome = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _page = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── pages ──────────────────────────────────────────
            PageView.builder(
              controller: _page,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final p = photos[i];
                return GestureDetector(
                  onTap: () => setState(() => _chrome = !_chrome),
                  child: Center(
                    child: Hero(
                      tag: 'lbphoto_${p.url}',
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Image(
                          image: appCachedImageProvider(p.url),
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white38,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // ── top chrome: close + counter ────────────────────
            AnimatedOpacity(
              opacity: _chrome ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _TopBar(
                index: _index,
                total: photos.length,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
            // ── bottom chrome: caption ─────────────────────────
            if (photos.isNotEmpty)
              AnimatedOpacity(
                opacity: _chrome ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _Caption(photo: photos[_index]),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.index,
    required this.total,
    required this.onClose,
  });
  final int index;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, MediaQuery.of(context).padding.top + 8, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            _CircleButton(icon: Icons.close_rounded, onTap: onClose),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${index + 1} / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.photo});
  final LinkBookPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(context).padding.bottom + 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.65),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              photo.activityTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  journalClock(photo.takenAt),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
