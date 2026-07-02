import '../../../../../index/index_main.dart';

class ClassroomShimmer extends StatelessWidget {
  const ClassroomShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
    itemCount: 6,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 88.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    ),
  );
}
