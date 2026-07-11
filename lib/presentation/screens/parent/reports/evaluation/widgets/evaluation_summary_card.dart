import '../../../../../../index/index_main.dart';
import 'daily_rating_style.dart';

/// Hero card: the dominant rating emoji + label for the week and how many of
/// the working days were assessed.
class EvaluationSummaryCard extends StatelessWidget {
  final WeeklyEvaluationController controller;
  const EvaluationSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rating = controller.dominant.value;
      final color = DailyRatingStyle.color(rating);
      return Container(
        padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(DailyRatingStyle.emoji(rating),
                  style: TextStyle(fontSize: 40.sp)),
            ),
            SizedBox(height: 14.h),
            Text(DailyRatingStyle.labelKey(rating).tr,
                style: context.typography.lgBold.copyWith(color: color)),
            SizedBox(height: 4.h),
            Text(
              'report_eval_assessed'.trParams({
                'done': '${controller.assessedCount.value}',
                'total': '${controller.workingDaysCount.value}',
              }),
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    });
  }
}
