import '../../../../../../index/index_main.dart';
import 'daily_rating_style.dart';

/// Day-by-day teacher assessment: each day shows its rating and the teacher's
/// comment (or a gentle placeholder when there is none / not assessed yet).
class EvaluationDayList extends StatelessWidget {
  final WeeklyEvaluationController controller;
  const EvaluationDayList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final days = controller.days;
      return Column(
        children: [
          for (final d in days)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _DayTile(day: d),
            ),
        ],
      );
    });
  }
}

class _DayTile extends StatelessWidget {
  final EvalDay day;
  const _DayTile({required this.day});

  @override
  Widget build(BuildContext context) {
    final rating = day.rating;
    final color = rating == null
        ? const Color(0xFF94A3B8)
        : DailyRatingStyle.color(rating);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: rating == null
                ? Icon(Icons.remove_rounded, color: color, size: 20.sp)
                : Text(DailyRatingStyle.emoji(rating),
                    style: TextStyle(fontSize: 20.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day.dayKey.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: const Color(0xFF1E293B))),
                    if (rating != null)
                      Text(DailyRatingStyle.labelKey(rating).tr,
                          style: context.typography.xsMedium
                              .copyWith(color: color)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  (day.comment != null && day.comment!.trim().isNotEmpty)
                      ? day.comment!.trim()
                      : (day.assessed
                          ? 'report_eval_no_comment'.tr
                          : 'report_eval_not_assessed'.tr),
                  style: context.typography.xsRegular.copyWith(
                    height: 1.4,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
