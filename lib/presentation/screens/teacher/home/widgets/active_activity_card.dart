import '../../../../../index/index_main.dart';
import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';
import 'pulsing_dot.dart';
import 'elapsed_timer.dart';

class ActiveActivityCard extends StatelessWidget {
  const ActiveActivityCard({
    super.key,
    required this.activity,
    required this.totalChildren,
    required this.onTap,
  });

  final ClassroomActivityModel activity;
  final int totalChildren;
  final VoidCallback onTap;

  static String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'teacher_home_time_pm'.tr : 'teacher_home_time_am'.tr;
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final evaluated = activity.evaluations.length;
    final total = activity.childIds.isNotEmpty
        ? activity.childIds.length
        : totalChildren;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.activityGreenDark,
              AppColors.activityGreen,
              AppColors.activityGreenAccent,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.activityGreen.withValues(alpha: 0.38),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PulsingDot(),
                  const SizedBox(width: 8),
                  Text(
                    'teacher_home_active_now'.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  ElapsedTimer(activity: activity),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                activity.title,
                style: context.typography.xlBold.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (activity.subjectName != null) ...[
                const SizedBox(height: 4),
                Text(
                  activity.subjectName!,
                  style: context.typography.smRegular.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${'teacher_home_started_at'.tr} ${_formatTime(activity.startedAt)}',
                    style: context.typography.xsRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$evaluated / $total ${'teacher_home_students_evaluated'.tr}',
                          style: context.typography.xsMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? evaluated / total : 0,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'teacher_home_continue'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.activityGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
