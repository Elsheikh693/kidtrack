import '../../../../../index/index_main.dart';

class ActivityShimmer extends StatelessWidget {
  const ActivityShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classroom selector chips
          Row(
            children: [
              _block(110, 36, r: 20),
              const SizedBox(width: 8),
              _block(90, 36, r: 20),
              const SizedBox(width: 8),
              _block(90, 36, r: 20),
            ],
          ),
          const SizedBox(height: 18),
          // Progress card
          _block(double.infinity, 88, r: 18),
          const SizedBox(height: 18),
          _block(140, 15, r: 6),
          const SizedBox(height: 14),
          // Timeline cards
          for (int i = 0; i < 3; i++) ...[
            const _TimelineSkeleton(),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          // CTA button
          _block(double.infinity, 56, r: 18),
        ],
      ),
    );
  }
}

Widget _block(double w, double h, {double r = 6}) => Shimmer.fromColors(
  baseColor: const Color(0xFFE2E8F0),
  highlightColor: const Color(0xFFF8FAFC),
  child: Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(r),
    ),
  ),
);

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _block(44, 44, r: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(double.infinity, 13),
                const SizedBox(height: 8),
                _block(120, 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _block(54, 26, r: 8),
        ],
      ),
    );
  }
}
