import '../../../../../index/index_main.dart';

/// Staff avatar: shows the profile photo when available, otherwise a colored
/// initials placeholder.
class StaffAvatar extends StatelessWidget {
  const StaffAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.color = AppColors.activityBlue,
    this.size = 44,
  });

  final String name;
  final String? imageUrl;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    if ((imageUrl ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image(
          image: appCachedImageProvider(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stack) => _initials(context, radius),
        ),
      );
    }
    return _initials(context, radius);
  }

  Widget _initials(BuildContext context, BorderRadius radius) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.typography.smSemiBold.copyWith(color: color),
      ),
    );
  }
}
