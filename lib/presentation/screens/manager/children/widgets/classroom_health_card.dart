import '../../../../../index/index_main.dart';
import '../models/class_health_data.dart';

/// One classroom's health as a compact grid tile: name, occupancy (children /
/// capacity) with a fill bar, and the assigned teacher — or a missing-teacher flag.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(
          () => const ClassroomExamsView(),
          arguments: {
            'classroomId': data.classroomId,
            'classroomName': data.name,
          },
          transition: Transition.rightToLeft,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
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
          Text(
            data.name,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.hasCapacity
                    ? '${data.enrolled} / ${data.capacity}'
                    : '${data.enrolled}',
                style: context.typography.smSemiBold.copyWith(color: _barColor),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  'manager_children_class_unit'.tr,
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ),
            ],
          ),
          // Fill bar only when a real capacity exists — otherwise there's no
          // meaningful ceiling to show progress against.
          if (data.hasCapacity) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: data.fillRate.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: AppColors.backgroundNeutralDefault,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
          ],
              const SizedBox(height: 10),
              _TeacherLine(data: data),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.assignment_rounded,
                      size: 14, color: AppColors.activityBlue),
                  const SizedBox(width: 5),
                  Text(
                    'exams_title'.tr,
                    style: context.typography.xsMedium
                        .copyWith(color: AppColors.activityBlue),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_left_rounded,
                      size: 16, color: AppColors.textSecondaryParagraph),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom line of the tile: the assigned teacher's name, a live-activity flag,
/// or a red "no teacher" warning.
class _TeacherLine extends StatelessWidget {
  const _TeacherLine({required this.data});

  final ClassHealthData data;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String label;
    final Color iconColor;
    Color textColor = AppColors.textSecondaryParagraph;

    if (data.teacherName.isNotEmpty) {
      icon = Icons.person_rounded;
      label = data.teacherName;
      iconColor = data.hasActiveActivity
          ? AppColors.activityGreen
          : AppColors.activityBlue;
      textColor = AppColors.textDefault;
    } else if (data.hasActiveActivity) {
      icon = Icons.play_circle_fill_rounded;
      label = 'manager_children_class_active_now'.tr;
      iconColor = textColor = AppColors.activityGreen;
    } else if (data.hasTeacher) {
      icon = Icons.person_rounded;
      label = 'manager_children_class_has_teacher'.tr;
      iconColor = textColor = AppColors.activityGreen;
    } else {
      icon = Icons.person_off_rounded;
      label = 'manager_children_class_no_teacher'.tr;
      iconColor = textColor = AppColors.activityRed;
    }

    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: context.typography.xsMedium.copyWith(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
