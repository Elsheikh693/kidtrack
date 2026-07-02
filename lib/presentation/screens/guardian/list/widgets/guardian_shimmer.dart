import '../../../../../index/index_main.dart';

class GuardianShimmer extends StatelessWidget {
  const GuardianShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 80.h, margin: EdgeInsets.only(bottom: 12.h), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r))),
      ),
    );
  }
}
