import '../../../../../index/index_main.dart';

class IdleProgressCard extends StatelessWidget {
  const IdleProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final pct = (completed / total).clamp(0.0, 1.0);
    final pctLabel = '${(pct * 100).round()}%';
    final remaining = total - completed;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.activityGreenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.activityGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt_rounded,
                color: AppColors.activityGreen,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'تم تنفيذ $completed من $total أنشطة اليوم',
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.activityGreenDark,
                  ),
                ),
              ),
              Text(
                pctLabel,
                style: context.typography.displaySmBold.copyWith(
                  color: AppColors.activityGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.activityGreen.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.activityGreen),
              minHeight: 6,
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 7),
            Text(
              'متبقي $remaining ${remaining == 1 ? 'نشاط' : 'أنشطة'}',
              style: context.typography.xsMedium.copyWith(
                color: AppColors.activityGreen.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
