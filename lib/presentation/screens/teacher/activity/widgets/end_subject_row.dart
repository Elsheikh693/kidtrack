import '../../../../../index/index_main.dart';
import '../activity_end_controller.dart';
import 'activity_chip.dart';

class EndSubjectRow extends StatelessWidget {
  const EndSubjectRow({super.key, required this.endCtrl});
  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    final subjects = endCtrl.subjects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'teacher_end_hw_subject'.tr,
          style: context.typography.xsMedium
              .copyWith(color: AppColors.textPrimaryParagraph),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActivityChip(
                  label: 'teacher_end_hw_no_subject'.tr,
                  isSelected: endCtrl.selectedSubjectId.value == null,
                  color: Colors.grey.shade600,
                  onTap: () => endCtrl.selectSubject(null, null),
                ),
                ...subjects.map((s) => ActivityChip(
                      label: s.name,
                      isSelected: endCtrl.selectedSubjectId.value == s.key,
                      color: AppColors.activityGreen,
                      onTap: () => endCtrl.selectSubject(s.key, s.name),
                    )),
              ],
            )),
      ],
    );
  }
}
