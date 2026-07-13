import '../../../../../index/index_main.dart';
import '../models/teaching_slice.dart';

/// One legend row under the donut: color swatch + class name, with the subject
/// being taught and the teacher on the line below. Tapping opens the drill-down.
class TeachingLegendTile extends StatelessWidget {
  const TeachingLegendTile({
    super.key,
    required this.slice,
    required this.onTap,
  });

  final TeachingSlice slice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.chartTrack),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: slice.color,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slice.className,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smSemiBold.copyWith(
                      color: AppColors.textDefault,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${slice.subjectLabel} · ${slice.teacherName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_left_rounded,
              size: 20.sp,
              color: AppColors.textSecondaryParagraph,
            ),
          ],
        ),
      ),
    );
  }
}
