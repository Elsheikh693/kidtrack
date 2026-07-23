import '../../../../../index/index_main.dart';

/// Skeleton placeholder shown while a report screen loads its first snapshot.
/// Mirrors the shared report layout — week bar, a hero card, then supporting
/// cards and rows — so the screen never flashes a bare spinner.
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _block(height: 54.h, radius: 14.r),
          SizedBox(height: 16.h),
          _block(height: 200.h, radius: 18.r),
          SizedBox(height: 12.h),
          _block(height: 88.h, radius: 16.r),
          SizedBox(height: 12.h),
          _block(height: 120.h, radius: 16.r),
          SizedBox(height: 12.h),
          for (var i = 0; i < 4; i++) ...[
            _block(height: 46.h, radius: 14.r),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _block({required double height, required double radius}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
