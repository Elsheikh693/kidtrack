import '../../../../../index/index_main.dart';
import '../models/class_health_data.dart';

/// One classroom's occupancy + staffing health. Surfaces the two things a
/// manager acts on: missing teacher, and over/at capacity.
class ClassroomHealthCard extends StatelessWidget {
  const ClassroomHealthCard({super.key, required this.data});

  final ClassHealthData data;

  Color get _barColor {
    if (data.isOverCapacity || data.isFull) return AppColors.activityRed;
    if (data.isAlmostFull) return AppColors.activityAmberBrand;
    return AppColors.activityGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.hasIssue
              ? _barColor.withValues(alpha: 0.35)
              : AppColors.grayLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.name,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${data.enrolled}',
                style: context.typography.smSemiBold.copyWith(color: _barColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: data.fillRate.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.backgroundNeutralDefault,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // A running activity means a teacher is present right now, so the
              // live badge replaces the static teacher chip entirely.
              if (data.hasActiveActivity)
                _Chip(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'manager_children_class_active_now'.tr,
                  color: AppColors.activityGreen,
                )
              else
                _Chip(
                  icon: data.hasTeacher
                      ? Icons.person_rounded
                      : Icons.person_off_rounded,
                  label: data.hasTeacher
                      ? 'manager_children_class_has_teacher'.tr
                      : 'manager_children_class_no_teacher'.tr,
                  color: data.hasTeacher
                      ? AppColors.activityGreen
                      : AppColors.activityRed,
                ),
              if (data.isOverCapacity || data.isFull)
                _Chip(
                  icon: Icons.warning_amber_rounded,
                  label: data.isOverCapacity
                      ? 'manager_children_class_over'.tr
                      : 'manager_children_class_full'.tr,
                  color: AppColors.activityRed,
                ),
              if (data.pending > 0)
                _Chip(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'manager_children_class_pending'
                      .trParams({'count': '${data.pending}'}),
                  color: AppColors.activityBlue,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: context.typography.xsMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
