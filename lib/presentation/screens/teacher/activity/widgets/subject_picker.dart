import '../../../../../index/index_main.dart';
import 'activity_chip.dart';

class SubjectPicker extends StatelessWidget {
  const SubjectPicker({
    super.key,
    required this.subjects,
    required this.selected,
    required this.onSelect,
  });

  final List<SubjectModel> subjects;
  final SubjectModel? selected;
  final ValueChanged<SubjectModel?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'teacher_activity_no_subjects'.tr,
          style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActivityChip(
          label: 'teacher_activity_no_subject'.tr,
          isSelected: selected == null,
          color: Colors.grey.shade600,
          onTap: () => onSelect(null),
        ),
        ...subjects.map((s) => ActivityChip(
              label: s.name,
              isSelected: selected?.key == s.key,
              color: AppColors.activityGreen,
              onTap: () => onSelect(s),
            )),
      ],
    );
  }
}
