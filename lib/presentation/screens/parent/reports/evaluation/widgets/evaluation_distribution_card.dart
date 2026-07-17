import '../../../../../../index/index_main.dart';
import 'daily_rating_style.dart';

/// A small bar breakdown of how the week's ratings were distributed across the
/// four levels.
class EvaluationDistributionCard extends StatelessWidget {
  final WeeklyEvaluationController controller;
  const EvaluationDistributionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
      child: Obx(() {
        final total = controller.evalCount.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 14.h, right: 2.w),
              child: Text('report_eval_distribution'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B))),
            ),
            _Row(
              rating: EvalLevel.excellent,
              value: controller.excellentCount.value,
              total: total,
            ),
            _Row(
              rating: EvalLevel.needsFollow,
              value: controller.needsFollowCount.value,
              total: total,
            ),
            _Row(
              rating: EvalLevel.needsAttention,
              value: controller.needsAttentionCount.value,
              total: total,
            ),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  final EvalLevel rating;
  final int value;
  final int total;
  const _Row({required this.rating, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = DailyRatingStyle.color(rating);
    final fraction = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 74.w,
            child: Text(DailyRatingStyle.labelKey(rating).tr,
                style: context.typography.xsMedium
                    .copyWith(color: const Color(0xFF475569))),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8.h,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 18.w,
            child: Text('$value',
                textAlign: TextAlign.end,
                style: context.typography.lgBold.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
