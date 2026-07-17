import '../../../../../../index/index_main.dart';
import 'daily_eval_style.dart';

/// Monthly teacher evaluation: the dominant level plus a segmented bar showing
/// how the month's activity evaluations were distributed across the 3 levels.
class MonthlyEvaluationCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyEvaluationCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.evalTotal;
      final rating = controller.dominant.value;
      final color = DailyEvalStyle.color(rating);
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(DailyEvalStyle.icon(rating),
                      color: color, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('report_evaluation_title'.tr,
                          style: context.typography.xsRegular
                              .copyWith(color: const Color(0xFF94A3B8))),
                      SizedBox(height: 2.h),
                      Text(
                        total == 0
                            ? 'report_eval_not_assessed'.tr
                            : DailyEvalStyle.labelKey(rating).tr,
                        style: context.typography.mdBold.copyWith(
                            color: total == 0
                                ? const Color(0xFF94A3B8)
                                : color),
                      ),
                    ],
                  ),
                ),
                if (total > 0)
                  Text(
                    'report_eval_assessed_short'.trParams({'n': '$total'}),
                    style: context.typography.xsMedium
                        .copyWith(color: const Color(0xFF64748B)),
                  ),
              ],
            ),
            if (total > 0) ...[
              SizedBox(height: 14.h),
              _SegmentBar(
                excellent: controller.excellentCount.value,
                needsFollow: controller.needsFollowCount.value,
                needsAttention: controller.needsAttentionCount.value,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _Legend(
                      color: DailyEvalStyle.excellent,
                      value: controller.excellentCount.value),
                  _Legend(
                      color: DailyEvalStyle.needsFollow,
                      value: controller.needsFollowCount.value),
                  _Legend(
                      color: DailyEvalStyle.needsAttention,
                      value: controller.needsAttentionCount.value),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      );
}

class _SegmentBar extends StatelessWidget {
  final int excellent;
  final int needsFollow;
  final int needsAttention;
  const _SegmentBar({
    required this.excellent,
    required this.needsFollow,
    required this.needsAttention,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: SizedBox(
        height: 10.h,
        child: Row(
          children: [
            if (excellent > 0)
              Expanded(
                  flex: excellent,
                  child: Container(color: DailyEvalStyle.excellent)),
            if (needsFollow > 0)
              Expanded(
                  flex: needsFollow,
                  child: Container(color: DailyEvalStyle.needsFollow)),
            if (needsAttention > 0)
              Expanded(
                  flex: needsAttention,
                  child: Container(color: DailyEvalStyle.needsAttention)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final int value;
  const _Legend({required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text('$value',
              style: context.typography.xsBold
                  .copyWith(color: const Color(0xFF334155))),
        ],
      ),
    );
  }
}
