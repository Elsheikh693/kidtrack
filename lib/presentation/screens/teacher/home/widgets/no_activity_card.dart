import '../../../../../index/index_main.dart';

class NoActivityCard extends StatelessWidget {
  const NoActivityCard({
    super.key,
    required this.onTap,
    this.activitiesDone = 0,
    this.activitiesTotal = 0,
  });

  final VoidCallback onTap;
  final int activitiesDone;
  final int activitiesTotal;

  @override
  Widget build(BuildContext context) {
    final hasActivities = activitiesTotal > 0;
    final progress =
        hasActivities ? activitiesDone / activitiesTotal : 0.0;
    final remaining = activitiesTotal - activitiesDone;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.activityGreen.withValues(alpha: 0.20),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.activityGreen.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.activityGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.activityGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasActivities && remaining > 0
                            ? '$remaining أنشطة متبقية اليوم'
                            : 'teacher_home_no_active_title'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.activitySlate),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasActivities
                            ? '$activitiesDone من $activitiesTotal مكتملة'
                            : 'teacher_home_no_active_hint'.tr,
                        style: context.typography.xsRegular
                            .copyWith(color: AppColors.activityMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.activityGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'teacher_home_start'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            if (hasActivities) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      AppColors.activityGreen.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.activityGreen,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
