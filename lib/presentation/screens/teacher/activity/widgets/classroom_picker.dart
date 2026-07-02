import '../../../../../index/index_main.dart';
import 'activity_chip.dart';

class ClassroomPicker extends StatelessWidget {
  const ClassroomPicker({
    super.key,
    required this.classrooms,
    required this.selected,
    required this.onSelect,
  });

  final List<ClassroomModel> classrooms;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: classrooms
          .map((c) => ActivityChip(
                label: c.name,
                isSelected: selected == c.key,
                color: AppColors.activityPurple,
                onTap: () => onSelect(c.key),
              ))
          .toList(),
    );
  }
}
