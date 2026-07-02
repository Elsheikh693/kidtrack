import '../../../../index/index_main.dart';

const _subjectColors = <String, Color>{
  'parent_course_arabic': Color(0xFFE67E22),
  'parent_course_english': Color(0xFF2980B9),
  'parent_course_math': Color(0xFF8E44AD),
  'parent_course_quran': Color(0xFF27AE60),
};

const _subjectIcons = <String, IconData>{
  'parent_course_arabic': Icons.menu_book_rounded,
  'parent_course_english': Icons.translate_rounded,
  'parent_course_math': Icons.calculate_rounded,
  'parent_course_quran': Icons.auto_stories_rounded,
};

class SubjectsAllView extends StatelessWidget {
  const SubjectsAllView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ParentEducationController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_forward_ios_rounded,
                size: 18, color: AppColors.textDefault),
          ),
          title: Text(
            'المواد الدراسية',
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
                height: 1,
                color:
                    AppColors.borderNeutralPrimary.withValues(alpha: 0.4)),
          ),
        ),
        body: Obx(() {
          final subjects = ctrl.subjects;
          if (subjects.isEmpty) {
            return Center(
              child: Text(
                'لا توجد مواد دراسية',
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _SubjectListTile(subject: subjects[i]),
          );
        }),
      ),
    );
  }
}

// ── Subject list tile ─────────────────────────────────────────────────────────

class _SubjectListTile extends StatelessWidget {
  const _SubjectListTile({required this.subject});
  final EduSubject subject;

  Color get _color =>
      _subjectColors[subject.nameKey] ?? AppColors.primary;
  IconData get _icon =>
      _subjectIcons[subject.nameKey] ?? Icons.book_rounded;

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: _color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.nameKey.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                const SizedBox(height: 3),
                Text(
                  subject.lastActivityTitle,
                  style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.textSecondaryParagraph
                            .withValues(alpha: 0.7)),
                    const SizedBox(width: 3),
                    Text(
                      subject.lastUpdated,
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph
                            .withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Rating badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _ratingColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
