import '../../../../../../index/index_main.dart';

/// Multi-select chips for the classrooms a run targets.
class RunClassroomSelector extends StatelessWidget {
  final List<ClassroomModel> classrooms;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;

  const RunClassroomSelector({
    super.key,
    required this.classrooms,
    required this.selectedIds,
    required this.onToggle,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    if (classrooms.isEmpty) {
      return Text('assessment_run_no_classrooms'.tr,
          style: context.typography.smRegular
              .copyWith(color: const Color(0xFF94A3B8)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in classrooms) _chip(context, c),
      ],
    );
  }

  Widget _chip(BuildContext context, ClassroomModel c) {
    final id = c.key ?? '';
    final selected = selectedIds.contains(id);
    return GestureDetector(
      onTap: () => onToggle(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 15, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              c.name,
              style: context.typography.smMedium.copyWith(
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
