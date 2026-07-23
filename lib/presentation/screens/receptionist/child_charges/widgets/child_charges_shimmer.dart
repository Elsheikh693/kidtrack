import '../../../../../index/index_main.dart';

/// Loading skeleton for the daily-expenses list — mirrors the charge card
/// footprint so the swap-in feels instant.
class ChildChargesShimmer extends StatelessWidget {
  const ChildChargesShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 90.h),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: const Color(0xFFF8FAFC),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            height: 108.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      );
}
