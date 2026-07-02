import '../../../../../index/index_main.dart';
import 'eval_chip.dart';
import 'eval_progress_bar.dart';

class CompletedActivityTile extends StatelessWidget {
  const CompletedActivityTile({super.key, required this.activity});

  final ClassroomActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final total = activity.evaluations.length;
    final excellent =
        activity.evaluations.values.where((v) => v == 'excellent').length;
    final follow =
        activity.evaluations.values.where((v) => v == 'needs_follow').length;
    final attention =
        activity.evaluations.values.where((v) => v == 'needs_attention').length;

    final startDt = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final timeLabel =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.activityGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.activityGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: context.typography.displaySmBold
                              .copyWith(color: AppColors.textDisplay),
                        ),
                        if (activity.subjectName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            activity.subjectName!,
                            style: context.typography.xsMedium
                                .copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeLabel,
                        style: context.typography.xsMedium
                            .copyWith(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activity.elapsedLabel,
                          style: context.typography.xsMedium
                              .copyWith(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (total > 0) ...[
              Container(height: 0.5, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (excellent > 0) ...[
                          EvalChip(
                            icon: Icons.star_rounded,
                            count: excellent,
                            color: AppColors.activityGreen,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (follow > 0) ...[
                          EvalChip(
                            icon: Icons.remove_red_eye_rounded,
                            count: follow,
                            color: AppColors.activityAmber,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (attention > 0) ...[
                          EvalChip(
                            icon: Icons.report_problem_rounded,
                            count: attention,
                            color: AppColors.activityRed,
                          ),
                          const SizedBox(width: 6),
                        ],
                        const Spacer(),
                        Text(
                          '$total ${'teacher_activity_evaluations'.tr}',
                          style: context.typography.xsMedium
                              .copyWith(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    EvalProgressBar(
                      excellent: excellent,
                      follow: follow,
                      attention: attention,
                      total: total,
                    ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
