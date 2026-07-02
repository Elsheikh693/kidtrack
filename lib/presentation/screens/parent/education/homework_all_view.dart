import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/teacher_notes_section.dart';

const _hwTitles = <String, String>{
  'hw_english_1': 'تمارين حروف الأبجدية الإنجليزية',
  'hw_math_1':    'تمارين الأعداد من 1 إلى 20',
  'hw_arabic_1':  'تمارين حرف الألف',
  'hw_quran_1':   'حفظ سورة الفاتحة',
};

const _subjectColors = <String, Color>{
  'parent_course_arabic':  Color(0xFFE67E22),
  'parent_course_english': Color(0xFF2980B9),
  'parent_course_math':    Color(0xFF8E44AD),
  'parent_course_quran':   Color(0xFF27AE60),
};

const _subjectIcons = <String, IconData>{
  'parent_course_arabic':  Icons.menu_book_rounded,
  'parent_course_english': Icons.translate_rounded,
  'parent_course_math':    Icons.calculate_rounded,
  'parent_course_quran':   Icons.auto_stories_rounded,
};

class HomeworkAllView extends StatelessWidget {
  const HomeworkAllView({super.key});

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
            child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.textDefault),
          ),
          title: Text(
            'الواجبات',
            style: context.typography.smSemiBold.copyWith(color: AppColors.textDefault),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4)),
          ),
        ),
        body: Column(
          children: [
            // ── Date dropdown ──────────────────────────────────────────────────
            _DateSelector(ctrl: ctrl),
            // ── Content ────────────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final day = ctrl.selectedDay;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _HomeworkDaySection(day: day),
                    if (day.notes.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      TeacherNotesSection(notes: day.notes),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Today header ──────────────────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.ctrl});
  final ParentEducationController ctrl;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'اليوم — $dateStr',
              style: context.typography.smMedium
                  .copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            Obx(() {
              final total = ctrl.homework.length;
              final done  = ctrl.completedHomework.length;
              if (total == 0) return const SizedBox.shrink();
              return Text(
                '$done / $total',
                style: context.typography.xsMedium.copyWith(
                  color: done == total
                      ? AppColors.successForeground
                      : AppColors.textSecondaryParagraph,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Homework section for a selected day ───────────────────────────────────────

class _HomeworkDaySection extends StatelessWidget {
  const _HomeworkDaySection({required this.day});
  final HomeworkDay day;

  @override
  Widget build(BuildContext context) {
    final done  = day.homeworkList.where((h) => h.isCompleted).length;
    final total = day.homeworkList.length;
    final pct   = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E44AD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_rounded, size: 15, color: Color(0xFF8E44AD)),
              ),
              const SizedBox(width: 10),
              Text(
                'الواجبات',
                style: context.typography.smSemiBold.copyWith(color: AppColors.textDefault),
              ),
              const Spacer(),
              Text(
                '$done / $total مكتمل',
                style: context.typography.xsRegular.copyWith(
                  color: done == total && total > 0
                      ? AppColors.successForeground
                      : AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                done == total && total > 0
                    ? AppColors.successForeground
                    : const Color(0xFF8E44AD),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // tiles
          ...day.homeworkList.map((hw) => _HomeworkReadTile(hw: hw)),
        ],
      ),
    );
  }
}

// ── Read-only homework tile ────────────────────────────────────────────────────

class _HomeworkReadTile extends StatelessWidget {
  const _HomeworkReadTile({required this.hw});
  final EduHomework hw;

  Color get _accent => _subjectColors[hw.subjectKey] ?? AppColors.primary;
  IconData get _icon => _subjectIcons[hw.subjectKey] ?? Icons.assignment_rounded;

  @override
  Widget build(BuildContext context) {
    final done   = hw.isCompleted;
    final accent = done ? AppColors.successForeground : _accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: done ? AppColors.successBackground : AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? AppColors.successForeground.withValues(alpha: 0.3)
              : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: done ? AppColors.successForeground : AppColors.grayMedium,
            size: 22,
          ),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, size: 15, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hw.displayTitle ?? _hwTitles[hw.titleKey] ?? hw.titleKey,
                  style: context.typography.smMedium.copyWith(
                    color: done ? AppColors.textSecondaryParagraph : AppColors.textDefault,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textSecondaryParagraph,
                  ),
                ),
                Text(
                  hw.subjectKey.tr,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
          Text(
            hw.dueDate,
            style: context.typography.xsRegular.copyWith(
              color: done ? AppColors.successForeground : AppColors.errorForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
