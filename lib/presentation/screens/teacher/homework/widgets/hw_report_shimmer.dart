import '../../../../../index/index_main.dart';

class HwReportShimmer extends StatelessWidget {
  const HwReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        const _SummarySkeleton(),
        const SizedBox(height: 16),
        _bar(w: 150, h: 15),
        const SizedBox(height: 14),
        for (int i = 0; i < 4; i++) const _CardSkeleton(),
      ],
    );
  }
}

Widget _bar({required double w, required double h, double r = 6}) =>
    Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
        ),
      ),
    );

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _block(46, 46, r: 13),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _block(double.infinity, 14),
                                const SizedBox(height: 8),
                                _block(140, 11),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _block(70, 22, r: 8),
                                    const SizedBox(width: 8),
                                    _block(60, 22, r: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _block(double.infinity, 8, r: 4),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _block(54, 24, r: 8),
                          const SizedBox(width: 8),
                          _block(54, 24, r: 8),
                          const Spacer(),
                          _block(30, 30, r: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
