import '../../../../../index/index_main.dart';

/// One exam row in the staff list: subject/title, date and a graded-progress
/// line. Tap opens grading; the overflow menu deletes (with confirm).
class ExamListCard extends StatelessWidget {
  const ExamListCard({
    super.key,
    required this.exam,
    required this.gradedCount,
    required this.rosterSize,
    required this.onTap,
    required this.onDelete,
  });

  final ExamModel exam;
  final int gradedCount;
  final int rosterSize;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final heading = exam.title.trim().isNotEmpty ? exam.title : exam.subjectName;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.assignment_rounded,
                    color: AppColors.primary, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: heading,
                      maxLines: 1,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textPrimaryParagraph),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      text: '${exam.subjectName} · ${_date(exam.examDate)}',
                      maxLines: 1,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                    SizedBox(height: 8.h),
                    _progress(context),
                  ],
                ),
              ),
              _menu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progress(BuildContext context) {
    final done = rosterSize > 0 && gradedCount >= rosterSize;
    final color = done ? AppColors.activityGreen : AppColors.primary;
    final label = rosterSize > 0
        ? '$gradedCount/$rosterSize ${'exam_graded_suffix'.tr}'
        : '$gradedCount ${'exam_graded_count'.tr}';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.edit_note_rounded,
              size: 13.r, color: color),
          SizedBox(width: 5.w),
          AppText(
            text: label,
            textStyle: context.typography.xsMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          color: AppColors.textSecondaryParagraph, size: 20.r),
      onSelected: (_) => _confirmDelete(context),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: AppText(
            text: 'exam_delete'.tr,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.errorForeground),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: AppText(
          text: 'exam_delete_confirm_title'.tr,
          textStyle: context.typography.smSemiBold
              .copyWith(color: AppColors.textPrimaryParagraph),
        ),
        content: AppText(
          text: 'exam_delete_confirm_body'.tr,
          maxLines: 3,
          overflow: TextOverflow.visible,
          textStyle: context.typography.smRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: AppText(
              text: 'cancel'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete();
            },
            child: AppText(
              text: 'exam_delete'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
  }

  static String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}
