import '../../../../index/index_main.dart';

/// A soft shimmering skeleton shown while an assessment / exam list loads —
/// nicer than a spinner and hints at the card layout that's coming.
class AssessmentListShimmer extends StatelessWidget {
  final int count;
  const AssessmentListShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, _) => const _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE9EDF2),
        highlightColor: Colors.white,
        child: Row(
          children: [
            _box(46, 46, 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(140, 13, 6),
                  const SizedBox(height: 8),
                  _box(90, 11, 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _box(44, 20, 10),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, double r) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
        ),
      );
}
