import '../../../../../index/index_main.dart';

class ReportActivityShimmer extends StatelessWidget {
  const ReportActivityShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        const _StatsSkeleton(),
        const SizedBox(height: 22),
        _bar(w: 170, h: 15),
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

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE2E8F0),
    highlightColor: const Color(0xFFF8FAFC),
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Row(
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
                                _block(80, 20, r: 6),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _block(46, 20, r: 8),
                              const SizedBox(height: 5),
                              _block(56, 20, r: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: const Color(0xFFF3F4F6)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Row(
                        children: [
                          _block(48, 24, r: 8),
                          const SizedBox(width: 10),
                          _block(36, 16, r: 6),
                          const Spacer(),
                          _block(36, 14, r: 6),
                          const SizedBox(width: 8),
                          _block(30, 30, r: 10),
                        ],
                      ),
                    ),
                  ],
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
