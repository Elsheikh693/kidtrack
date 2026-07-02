import '../../../../../index/index_main.dart';

class EducationShimmer extends StatelessWidget {
  const EducationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher notes card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(),
                  const SizedBox(height: 14),
                  for (int i = 0; i < 3; i++) ...[
                    _block(double.infinity, 48, r: 12),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Homework card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(),
                  const SizedBox(height: 14),
                  _block(double.infinity, 44, r: 12),
                  const SizedBox(height: 10),
                  _block(double.infinity, 44, r: 12),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Subjects card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        _block(130, 150, r: 14),
                        const SizedBox(width: 10),
                        _block(130, 150, r: 14),
                        const SizedBox(width: 10),
                        _block(60, 150, r: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  static Widget _row() => Row(
    children: [
      _block(28, 28, r: 8),
      const SizedBox(width: 10),
      _block(120, 14),
    ],
  );

  static Widget _block(double w, double h, {double r = 6}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
