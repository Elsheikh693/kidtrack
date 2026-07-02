import '../../../../../index/index_main.dart';

/// Loading skeleton for the Children tab — mirrors the real layout (KPI grid,
/// classroom health, attention, directory) so the transition into loaded
/// content has no layout shift.
class ChildrenShimmer extends StatelessWidget {
  const ChildrenShimmer({super.key});

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
          _kpiGrid(),
          const SizedBox(height: 24),
          _sectionTitle(width: 120),
          const SizedBox(height: 12),
          _bar(height: 88),
          const SizedBox(height: 12),
          _bar(height: 88),
          const SizedBox(height: 24),
          _sectionTitle(width: 150),
          const SizedBox(height: 12),
          _bar(height: 64),
          const SizedBox(height: 24),
          _sectionTitle(width: 100),
          const SizedBox(height: 12),
          _bar(height: 48, radius: 12),
          const SizedBox(height: 12),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _bar(height: 72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final w = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            4,
            (_) => SizedBox(width: w, child: _bar(height: 104)),
          ),
        );
      },
    );
  }

  Widget _sectionTitle({required double width}) => _box(width: width, height: 16);

  Widget _bar({required double height, double radius = 16}) =>
      _box(height: height, radius: radius);

  Widget _box({double? width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
