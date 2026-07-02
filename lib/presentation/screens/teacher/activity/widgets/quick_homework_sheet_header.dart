import '../../../../../index/index_main.dart';

class QuickHomeworkSheetHeader extends StatelessWidget {
  const QuickHomeworkSheetHeader({super.key, this.subjectName});
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.activityAmberBrand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: AppColors.activityAmberBrand,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'teacher_homework_new'.tr,
              style: context.typography.lgBold,
            ),
            if (subjectName != null)
              Text(
                subjectName!,
                style: context.typography.xsMedium
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
          ],
        ),
      ],
    );
  }
}
