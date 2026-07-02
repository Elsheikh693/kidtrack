import '../../../../../index/index_main.dart';

class ProgramShimmer extends StatelessWidget {
  const ProgramShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
    itemCount: 5,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    ),
  );
}
