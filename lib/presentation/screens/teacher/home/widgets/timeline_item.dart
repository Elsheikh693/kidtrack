import 'dart:ui' show FontFeature;
import '../../../../../index/index_main.dart';
import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';

class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.activity,
    required this.isLast,
    required this.onTap,
  });

  final ClassroomActivityModel activity;
  final bool isLast;
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
    final isActive = activity.isActive;
    final dotColor = isActive ? AppColors.activityGreen : AppColors.activityGreen.withValues(alpha: 0.35);
    final statusLabel = isActive
        ? 'teacher_home_activity_active'.tr
        : 'teacher_home_activity_completed'.tr;
    final statusColor = isActive ? AppColors.activityGreen : AppColors.activityGreen;
    final statusBg = isActive
        ? AppColors.activityGreen.withValues(alpha: 0.10)
        : AppColors.activityGreenLight;
    final statusIcon = isActive
        ? Icons.radio_button_checked_rounded
        : Icons.check_circle_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.activityGreen.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.dividerAndLines,
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isActive ? onTap : null,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: isLast ? 14 : 10,
                  left: 16,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        _formatTime(activity.startedAt),
                        style: context.typography.xsMedium.copyWith(
                          color: AppColors.activityMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activity.title,
                            style: context.typography.smSemiBold
                                .copyWith(color: AppColors.activitySlate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (activity.subjectName != null)
                            Text(
                              activity.subjectName!,
                              style: context.typography.xsRegular
                                  .copyWith(color: AppColors.activityMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 11, color: statusColor),
                          const SizedBox(width: 3),
                          Text(
                            statusLabel,
                            style: context.typography.xsMedium
                                .copyWith(color: statusColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
