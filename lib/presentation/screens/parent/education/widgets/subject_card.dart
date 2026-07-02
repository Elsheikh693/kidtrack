import '../../../../../index/index_main.dart';

class EduSubjectCard extends StatelessWidget {
  const EduSubjectCard({super.key, required this.subject});

  final EduSubject subject;

  Color get _subjectColor {
    switch (subject.nameKey) {
      case 'parent_course_arabic':
        return const Color(0xFFE67E22);
      case 'parent_course_english':
        return const Color(0xFF2980B9);
      case 'parent_course_math':
        return const Color(0xFF8E44AD);
      case 'parent_course_quran':
        return const Color(0xFF27AE60);
      default:
        return AppColors.primary;
    }
  }

  IconData get _subjectIcon {
    switch (subject.nameKey) {
      case 'parent_course_arabic':
        return Icons.menu_book_rounded;
      case 'parent_course_english':
        return Icons.translate_rounded;
      case 'parent_course_math':
        return Icons.calculate_rounded;
      case 'parent_course_quran':
        return Icons.auto_stories_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Color get _ratingColor {
    switch (subject.ratingKey) {
      case 'parent_edu_rating_excellent':
        return AppColors.successForeground;
      case 'parent_edu_rating_very_good':
        return AppColors.primary;
      default:
        return AppColors.yellowForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 162,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _subjectColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _subjectColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _subjectColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_subjectIcon, color: _subjectColor, size: 22),
          ),
          const SizedBox(height: 10),
          // Subject name
          Text(
            subject.nameKey.tr,
            style: context.typography.smSemiBold.copyWith(color: AppColors.textDefault),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          // Last activity
          Text(
            subject.lastActivityTitle,
            style: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Last updated
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondaryParagraph.withValues(alpha: 0.7)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  subject.lastUpdated,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _ratingColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              subject.ratingKey.tr,
              style: TextStyle(
                color: _ratingColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
