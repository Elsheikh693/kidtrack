import '../../../../../index/index_main.dart';

class DiscoveryShimmer extends StatelessWidget {
  const DiscoveryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Column(
        children: List.generate(3, (_) => _card()),
      ),
    );
  }

  Widget _card() {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 168.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(140.w, 16.h),
                SizedBox(height: 10.h),
                _bar(100.w, 12.h),
                SizedBox(height: 14.h),
                _bar(double.infinity, 12.h),
                SizedBox(height: 16.h),
                _bar(double.infinity, 44.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
      );
}
