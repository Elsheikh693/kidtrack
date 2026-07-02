import '../../../../../index/index_main.dart';

/// Loading skeleton for the Dashboard tab — mirrors the real layout (pulse
/// banner, attention list, snapshot grid, finance summary) for a shift-free load.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      period: const Duration(milliseconds: 1100),
      // A non-scrolling Column — NOT a ListView. This widget renders inside a
      // SliverToBoxAdapter, which hands its child UNBOUNDED main-axis (height)
      // extent. A ListView is itself a vertical viewport and cannot accept
      // unbounded height (even with shrinkWrap), which threw "Vertical viewport
      // was given unbounded height" and cascaded into geometry-null layout
      // crashes. A Column sizes to its children's intrinsic heights and lays
      // out cleanly in that context.
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(width: 130),
            const SizedBox(height: 12),
            _bar(height: 150, radius: 20),
            const SizedBox(height: 12),
            _grid(),
            const SizedBox(height: 22),
            _bar(height: 96, radius: 22),
            const SizedBox(height: 24),
            _title(width: 160),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _bar(height: 66, radius: 14),
              ),
            ),
            const SizedBox(height: 22),
            _title(width: 130),
            const SizedBox(height: 12),
            _bar(height: 180, radius: 20),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
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

  Widget _title({required double width}) =>
      _box(width: width, height: 16, radius: 8);

  // Full-width bar. Inside a Column the cross axis is loose, so a width-less
  // Container would collapse to zero; double.infinity clamps to the parent's
  // max width and gives a true full-bleed bar.
  Widget _bar({required double height, double radius = 16}) =>
      _box(width: double.infinity, height: height, radius: radius);

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
