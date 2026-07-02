import '../../../../../index/index_main.dart';
import '../controller.dart';

class EduCourseProgressCard extends StatelessWidget {
  const EduCourseProgressCard({super.key, required this.course});

  final EduCourse course;

  Color get _color {
    if (course.progress >= 0.8) return AppColors.successForeground;
    if (course.progress >= 0.6) return AppColors.primary;
    return AppColors.yellowForeground;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (course.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      color: _color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  course.nameKey.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: course.progress,
              backgroundColor: AppColors.backgroundNeutral100,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.history_rounded, size: 12, color: AppColors.textSecondaryParagraph),
              const SizedBox(width: 4),
              Text(
                '${('parent_edu_last_activity').tr}: ${course.lastActivity}',
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.lastAssessment,
                  style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
