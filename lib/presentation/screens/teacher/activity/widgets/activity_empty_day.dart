import '../../../../../index/index_main.dart';

class ActivityEmptyDay extends StatelessWidget {
  const ActivityEmptyDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundNeutralDefault,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.event_note_rounded,
            size: 44,
            color: AppColors.grayMedium,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'teacher_activity_empty_day'.tr,
          style: context.typography.mdBold
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        const SizedBox(height: 4),
        Text(
          'teacher_activity_empty_day_sub'.tr,
          style: context.typography.xsMedium
              .copyWith(color: AppColors.grayMedium),
        ),
      ],
    );
  }
}
