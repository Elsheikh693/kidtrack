import '../../../../../index/index_main.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';
import 'activity_pulse_dot.dart';
import 'activity_elapsed_badge.dart';

class ActivityHeaderExpanded extends StatelessWidget {
  const ActivityHeaderExpanded({
    super.key,
    required this.activity,
    this.classroomName,
  });

  final ClassroomActivityModel activity;
  final String? classroomName;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (activity.subjectName != null) activity.subjectName!,
      if (classroomName != null) classroomName!,
    ];
    final metaText = parts.join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const ActivityPulseDot(),
              if (metaText.isNotEmpty) ...[
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    metaText,
                    style: context.typography.xsMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.78),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              ActivityElapsedBadge(startedAtMs: activity.startedAt),
            ],
          ),
          const SizedBox(height: 4),
          // Flexible so the title clips to an ellipsis as the sliver header
          // shrinks during scroll instead of overflowing the bounded box.
          Flexible(
            child: Text(
              activity.title,
              style: context.typography.lgBold.copyWith(
                color: AppColors.white,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
