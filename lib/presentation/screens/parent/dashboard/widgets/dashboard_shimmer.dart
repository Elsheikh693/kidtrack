import '../../../../../index/index_main.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live status card
            _card(
              height: 130,
              child: Row(
                children: [
                  _block(56, 56, r: 16),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _block(90, 14),
                      SizedBox(height: 10.h),
                      _block(150, 20),
                      SizedBox(height: 8.h),
                      _block(110, 12),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Payment reminder
            _labelRow(),
            SizedBox(height: 10.h),
            _card(height: 80),
            SizedBox(height: 20.h),
            // Photos row
            _labelRow(),
            SizedBox(height: 10.h),
            SizedBox(
              height: 96.h,
              child: Row(
                children: [
                  _block(96, 96, r: 14),
                  SizedBox(width: 10.w),
                  _block(96, 96, r: 14),
                  SizedBox(width: 10.w),
                  _block(96, 96, r: 14),
                ],
              )    ),
            SizedBox(height: 20.h),
            // Notes / schedule cards
            _labelRow(),
            SizedBox(height: 10.h),
            _card(height: 72),
            SizedBox(height: 12.h),
            _card(height: 72),
          ],
        ),
      ),
    );
  }

  static Widget _card({double? height, Widget? child}) => Container(
    height: height,
    width: double.infinity,
    padding: child == null ? null : EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
    ),
    child: child);

  static Widget _labelRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _block(60, 12),
      _block(120, 16),
    ],
  );

  static Widget _block(double w, double h, {double r = 6}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(r),
    ));
}
