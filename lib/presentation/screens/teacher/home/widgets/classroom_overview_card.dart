import '../../../../../index/index_main.dart';

class ClassroomOverviewCard extends StatelessWidget {
  const ClassroomOverviewCard({
    super.key,
    required this.classroom,
    required this.childCount,
    required this.activityCount,
    required this.avgRating,
    required this.attentionCount,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final int childCount;
  final int activityCount;
  final double avgRating;
  final int attentionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAttention = attentionCount > 0;

    final accent = hasAttention
        ? AppColors.activityRed
        : AppColors.activityBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: .08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.class_rounded, size: 20, color: accent),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      classroom.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.lgBold.copyWith(
                        color: AppColors.activitySlate,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasAttention
                          ? AppColors.activityRed.withValues(alpha: .08)
                          : AppColors.activityGreen.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasAttention
                          ? 'teacherhom35_alert'.tr
                          : 'teacherhom35_excellent'.tr,
                      style: context.typography.xsMedium.copyWith(
                        color: hasAttention
                            ? AppColors.activityRed
                            : AppColors.activityGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              _InfoRow(
                icon: Icons.groups_rounded,
                text: 'teacherhom35_students_count'
                    .trParams({'count': '$childCount'}),
                color: AppColors.activitySlate,
              ),

              const SizedBox(height: 8),

              _InfoRow(
                icon: Icons.check_circle_rounded,
                text: 'teacherhom35_activities_completed_count'
                    .trParams({'count': '$activityCount'}),
                color: AppColors.activityBlue,
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: hasAttention
                      ? AppColors.activityRed.withValues(alpha: .06)
                      : AppColors.activityGreen.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasAttention
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      size: 15,
                      color: hasAttention
                          ? AppColors.activityRed
                          : AppColors.activityGreen,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        hasAttention
                            ? 'teacherhom35_needs_followup_count'
                                .trParams({'count': '$attentionCount'})
                            : 'teacherhom35_no_alerts'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsMedium.copyWith(
                          color: hasAttention
                              ? AppColors.activityRed
                              : AppColors.activityGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: context.typography.xsMedium.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
