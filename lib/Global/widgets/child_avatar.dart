import '../../index/index_main.dart';

/// Shared avatar for a child, used everywhere a child appears in a card, tile
/// or list. Shows the guardian-uploaded photo ([imageUrl], disk + memory
/// cached via [AppNetworkImage]) when present, otherwise a tinted initial
/// fallback. Centralising this keeps the child's photo consistent app-wide.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
    this.color,
    this.circle = true,
    this.borderRadius,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// Accent used for the initial fallback background + text. Defaults to
  /// [AppColors.primary].
  final Color? color;

  /// Circle (default) or rounded square.
  final bool circle;

  /// Corner radius when [circle] is false. Defaults to `size * 0.28`.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    final trimmed = name.trim();
    final initial =
        trimmed.isNotEmpty ? trimmed.characters.first.toUpperCase() : '؟';
    final radius = circle ? size / 2 : (borderRadius ?? size * 0.28);

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        initial,
        style: _initialStyle(context).copyWith(color: accent),
      ),
    );

    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    if (!hasImage) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AppNetworkImage(
        url: imageUrl,
        width: size,
        height: size,
        errorWidget: fallback,
      ),
    );
  }

  TextStyle _initialStyle(BuildContext context) {
    if (size >= 48) return context.typography.lgBold;
    if (size >= 36) return context.typography.mdBold;
    return context.typography.smSemiBold;
  }
}
