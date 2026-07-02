import '../../../../../index/index_main.dart';

class QuickTasksCard extends StatelessWidget {
  const QuickTasksCard({
    super.key,
    required this.activitiesDone,
    required this.activitiesTotal,
    required this.studentsEvaluated,
    required this.attentionCount,
  });

  final int activitiesDone;
  final int activitiesTotal;
  final int studentsEvaluated;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    if (activitiesTotal == 0 && attentionCount == 0 && studentsEvaluated == 0) {
      return const SizedBox.shrink();
    }

    final progress =
        activitiesTotal > 0 ? activitiesDone / activitiesTotal : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.activityGreen.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'إنجازات اليوم',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.activitySlate),
              ),
              const Spacer(),
              if (activitiesTotal > 0)
                Text(
                  '$activitiesDone من $activitiesTotal أنشطة',
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.activityGreen),
                ),
            ],
          ),
          if (activitiesTotal > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    AppColors.activityGreen.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.activityGreen,
                ),
                minHeight: 5,
              ),
            ),
          ],
          if (studentsEvaluated > 0 || attentionCount > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (studentsEvaluated > 0)
                  _Chip(
                    icon: Icons.star_rounded,
                    label: '$studentsEvaluated تقييم',
                    color: AppColors.activityAmberBrand,
                  ),
                if (attentionCount > 0)
                  _Chip(
                    icon: Icons.warning_amber_rounded,
                    label: '$attentionCount يحتاج انتباه',
                    color: AppColors.activityRed,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
