import '../../../../../index/index_main.dart';

/// Skeleton shown while the checklist probes each step's completion. Mirrors the
/// real layout (progress header → grouped step cards) so the screen never flashes
/// empty or jumps when the data resolves.
class SetupHubShimmer extends StatelessWidget {
  const SetupHubShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _block(height: 168.h, radius: 22),
          SizedBox(height: 20.h),
          _label(width: 150.w),
          _block(height: 84.h),
          SizedBox(height: 18.h),
          _label(width: 190.w),
          _block(height: 84.h),
          _block(height: 84.h),
          _block(height: 84.h),
          SizedBox(height: 18.h),
          _label(width: 130.w),
          _block(height: 84.h),
        ],
      ),
    );
  }

  Widget _block({required double height, double radius = 18}) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _label({required double width}) => Container(
        margin: EdgeInsets.only(right: 4.w, bottom: 14.h, top: 4.h),
        width: width,
        height: 16.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
