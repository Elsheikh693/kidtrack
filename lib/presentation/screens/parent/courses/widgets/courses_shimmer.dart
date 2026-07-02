import '../../../../../index/index_main.dart';

class CoursesShimmer extends StatelessWidget {
  const CoursesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          const SizedBox(height: 10),
          for (int i = 0; i < 3; i++) const _CourseSkeleton(),
        ],
      ),
    );
  }
}

class _CourseSkeleton extends StatelessWidget {
  const _CourseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header placeholder
            Container(
              height: 96,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFE2E8F0),
              child: Row(
                children: [
                  _block(54, 54, r: 27),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _block(60, 18, r: 8),
                      const SizedBox(height: 8),
                      _block(120, 16),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _block(double.infinity, 12),
                  const SizedBox(height: 8),
                  _block(180, 12),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _block(90, 28, r: 10),
                      const SizedBox(width: 8),
                      _block(60, 28, r: 10),
                      const SizedBox(width: 8),
                      _block(70, 28, r: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(double w, double h, {double r = 6}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFCBD5E1),
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
