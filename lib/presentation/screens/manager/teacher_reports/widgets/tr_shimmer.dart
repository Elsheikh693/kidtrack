import '../../../../../index/index_main.dart';

/// Loading skeleton mirroring the teacher-reports layout (date bar, hero,
/// chart, teacher cards) to avoid layout shift on load.
class TrShimmer extends StatelessWidget {
  const TrShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1100),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _box(height: 48, radius: 16),
          const SizedBox(height: 12),
          _box(height: 44, radius: 13),
          const SizedBox(height: 20),
          _box(height: 150, radius: 24),
          const SizedBox(height: 20),
          _box(height: 230, radius: 20),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _box(height: 130, radius: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required double height, double radius = 8}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
