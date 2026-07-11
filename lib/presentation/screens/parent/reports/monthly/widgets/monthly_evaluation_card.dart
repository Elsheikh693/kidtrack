import '../../../../../../index/index_main.dart';

/// Monthly teacher evaluation summary: the dominant rating and how many days
/// were assessed.
class MonthlyEvaluationCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyEvaluationCard({super.key, required this.controller});

  Color _ratingColor(DailyRating r) {
    switch (r) {
      case DailyRating.excellent:
        return const Color(0xFF16A34A);
      case DailyRating.veryGood:
        return const Color(0xFF0891B2);
      case DailyRating.good:
        return const Color(0xFFD97706);
      case DailyRating.needsSupport:
        return const Color(0xFFDC2626);
    }
  }

  String _labelKey(DailyRating r) {
    switch (r) {
      case DailyRating.excellent:
        return 'report_rating_excellent';
      case DailyRating.veryGood:
        return 'report_rating_very_good';
      case DailyRating.good:
        return 'report_rating_good';
      case DailyRating.needsSupport:
        return 'report_rating_needs_support';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rating = controller.dominant.value;
      final color = _ratingColor(rating);
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(rating.emoji, style: TextStyle(fontSize: 26.sp)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_evaluation_title'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF94A3B8))),
                  SizedBox(height: 2.h),
                  Text(_labelKey(rating).tr,
                      style:
                          context.typography.mdBold.copyWith(color: color)),
                ],
              ),
            ),
            Text(
              'report_eval_assessed_short'
                  .trParams({'n': '${controller.assessedCount.value}'}),
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    });
  }
}
