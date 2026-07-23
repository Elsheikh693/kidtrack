import '../../../../../../index/index_main.dart';
import '../../../../shared/exams/exam_grade_meta.dart';

/// The 5 selectable verbal-grade pills. Purely presentational — the selected
/// grade is owned by the parent card.
class GradePills extends StatelessWidget {
  const GradePills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final ExamGrade? selected;
  final ValueChanged<ExamGrade> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ExamGrade.values.map((grade) {
        final meta = ExamGradeMeta.of(grade);
        final isSelected = selected == grade;
        return GestureDetector(
          onTap: () => onSelect(grade),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? meta.color
                  : meta.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isSelected ? meta.color : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(meta.emoji, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                AppText(
                  text: meta.label,
                  textStyle: context.typography.xsMedium.copyWith(
                    color: isSelected ? AppColors.white : meta.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
