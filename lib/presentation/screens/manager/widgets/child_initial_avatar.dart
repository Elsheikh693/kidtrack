import '../../../../index/index_main.dart';

/// Compact initials avatar used for children rows in the Branch Manager tabs.
class ChildInitialAvatar extends StatelessWidget {
  const ChildInitialAvatar({
    super.key,
    required this.name,
    required this.color,
    this.imageUrl,
    this.size = 44,
  });

  final String name;
  final Color color;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.typography.smSemiBold.copyWith(color: color),
      ),
    );
    if (imageUrl == null || imageUrl!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: AppNetworkImage(
        url: imageUrl,
        width: size,
        height: size,
        errorWidget: fallback,
      ),
    );
  }
}
