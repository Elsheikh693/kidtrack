import '../../../../../index/index_main.dart';

class ActivityEndGeneralNote extends StatelessWidget {
  const ActivityEndGeneralNote({super.key, required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.blueLightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.blueForeground,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'teacher_end_general_comment'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDisplay),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          textDirection: appTextDirection,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'teacher_end_general_comment_hint'.tr,
            hintTextDirection: TextDirection.rtl,
            hintStyle: context.typography.smRegular
                .copyWith(color: AppColors.textFieldPlaceholder),
            filled: true,
            fillColor: AppColors.backgroundNeutralDefault,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.activityGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
