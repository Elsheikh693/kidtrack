import 'package:cached_network_image/cached_network_image.dart';
import '../../index/index_main.dart';

/// Persistent (disk + memory) cached [ImageProvider] for network URLs.
///
/// Use this anywhere an [ImageProvider] is expected — e.g.
/// `CircleAvatar(backgroundImage: ...)` or `DecorationImage(image: ...)` —
/// instead of [NetworkImage], so the bytes are downloaded once and reused
/// from disk on later visits (and across app restarts).
ImageProvider appCachedImageProvider(String? url) {
  final resolved = url?.trim() ?? '';
  if (resolved.isEmpty) {
    // 1×1 transparent pixel so callers never get a null provider.
    return MemoryImage(_kTransparentPixel);
  }
  return CachedNetworkImageProvider(resolved);
}

final Uint8List _kTransparentPixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Network image widget with a persistent disk + memory cache
/// (via [cached_network_image]). Downloads each URL once and serves it
/// from disk on later visits — no repeated server round-trips per screen.
/// Shows shimmer while loading, fallback widget on error.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Widget shown when the image fails to load (or url is null/empty).
  final Widget? errorWidget;

  /// Optional clip radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolved = url?.trim() ?? '';

    Widget child;

    if (resolved.isEmpty) {
      child = _fallback();
    } else {
      child = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        // Disk + memory cached: bytes download once, reused on later visits.
        fadeInDuration: const Duration(milliseconds: 280),
        placeholder: (ctx, _) => _Shimmer(width: width, height: height),
        errorWidget: (ctx, _, _) => _fallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _fallback() =>
      errorWidget ??
      _Fallback(width: width, height: height);
}

// ──────────────────────────────────────────────────────────────────────────────
// Shimmer placeholder
// ──────────────────────────────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  const _Shimmer({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: AppColors.white,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Default fallback when URL is empty or load fails
// ──────────────────────────────────────────────────────────────────────────────

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
