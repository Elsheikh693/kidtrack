import '../../../../../index/index_main.dart';
import '../models/teaching_slice.dart';
import 'teaching_ring_painter.dart';

/// The donut itself: the painted ring with the active-class count stacked in
/// the hole. Tapping the center opens the first class in session.
class TeachingDonut extends StatelessWidget {
  const TeachingDonut({super.key, required this.slices});

  final List<TeachingSlice> slices;

  @override
  Widget build(BuildContext context) {
    final side = 220.w;
    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(side, side),
            painter: TeachingRingPainter(
              slices: slices,
              labelStyle: context.typography.smSemiBold.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${slices.length}',
                style: context.typography.xxlBold.copyWith(
                  color: AppColors.textDefault,
                  fontSize: 30.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'live_teaching_active_classes'.tr,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
