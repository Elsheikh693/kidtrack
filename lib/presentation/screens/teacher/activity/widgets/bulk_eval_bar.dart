import '../../../../../index/index_main.dart';
import 'eval_bulk_button.dart';

class BulkEvalBar extends StatelessWidget {
  const BulkEvalBar({
    super.key,
    required this.onEval,
    required this.progress,
    required this.evaluatedCount,
    required this.total,
    this.isLoading = false,
  });

  final void Function(EvalLevel) onEval;
  final double progress;
  final int evaluatedCount;
  final int total;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final isDone = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_alt_rounded,
                        size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'teacher_eval_rate_all'.tr,
                      style: context.typography.xsMedium
                          .copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '$evaluatedCount / $total',
                style: context.typography.xsMedium
                    .copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.activityGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct%',
                  style: context.typography.xsMedium.copyWith(
                    color: isDone
                        ? AppColors.activityGreen
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              EvalBulkButton(
                icon: Icons.star_rounded,
                labelKey: 'teacher_eval_excellent',
                color: AppColors.activityGreen,
                onTap: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onEval(EvalLevel.excellent);
                      },
              ),
              const SizedBox(width: 8),
              EvalBulkButton(
                icon: Icons.remove_red_eye_rounded,
                labelKey: 'teacher_eval_needs_follow',
                color: AppColors.activityAmber,
                onTap: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onEval(EvalLevel.needsFollow);
                      },
              ),
              const SizedBox(width: 8),
              EvalBulkButton(
                icon: Icons.report_problem_rounded,
                labelKey: 'teacher_eval_needs_attention',
                color: AppColors.activityRed,
                onTap: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onEval(EvalLevel.needsAttention);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
