import '../../../../../index/index_main.dart';

/// Skeleton placeholder shown while the executive dashboard loads its first
/// snapshot. Mirrors the real layout (brief → attention → finance → growth) so
/// the screen never appears empty or heavy on open.
class OwnerExecShimmer extends StatelessWidget {
  const OwnerExecShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(height: 158, radius: 22),
          _label(width: 150),
          _block(height: 78),
          _block(height: 78),
          _label(width: 120),
          _block(height: 152, radius: 20),
          _label(width: 130),
          _block(height: 152, radius: 20),
        ],
      ),
    );
  }

  Widget _block({required double height, double radius = 18}) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _label({required double width}) => Container(
        margin: const EdgeInsets.fromLTRB(4, 10, 0, 14),
        width: width,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
