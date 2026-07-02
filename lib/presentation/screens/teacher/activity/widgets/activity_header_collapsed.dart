import '../../../../../index/index_main.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';
import 'activity_pulse_dot.dart';
import 'activity_elapsed_badge.dart';

class ActivityHeaderCollapsed extends StatelessWidget {
  const ActivityHeaderCollapsed({
    super.key,
    required this.activity,
  });

  final ClassroomActivityModel activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const ActivityPulseDot(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.title,
              style: context.typography.mdBold.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          ActivityElapsedBadge(startedAtMs: activity.startedAt),
        ],
      ),
    );
  }
}
