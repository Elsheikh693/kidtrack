import '../../../../../index/index_main.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        children: [
          // Header block (avatar + name)
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(140, 16),
                  const SizedBox(height: 8),
                  _bar(90, 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick stats
          _block(72),
          const SizedBox(height: 12),
          // Section cards
          _block(120),
          const SizedBox(height: 12),
          _block(100),
          const SizedBox(height: 12),
          _block(140),
        ],
      ),
    );
  }

  static Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  static Widget _block(double h) => Container(
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}
