import '../../../../../index/index_main.dart';

class AuditShimmer extends StatelessWidget {
  const AuditShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
    itemCount: 6,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0), highlightColor: const Color(0xFFF8FAFC),
      child: Container(margin: EdgeInsets.only(bottom: 10.h), height: 80.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r))),
    ),
  );
}
