import '../../../../../index/index_main.dart';

/// Full-screen preview of a single photo with pinch-to-zoom. Opened by tapping
/// a photo in the reviewer's grid.
class FullPhotoView extends StatelessWidget {
  const FullPhotoView({super.key, required this.url});

  final String url;

  static Future<void> show(BuildContext context, String url) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (ctx, a1, a2) => FullPhotoView(url: url),
        transitionsBuilder: (ctx, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image(
                  image: appCachedImageProvider(url),
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 8,
            end: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 1),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
