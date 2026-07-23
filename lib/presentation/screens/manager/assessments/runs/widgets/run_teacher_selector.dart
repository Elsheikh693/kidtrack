import '../../../../../../index/index_main.dart';

/// Single-select chips for the (optional) teacher who will run the assessment.
/// Tapping the selected chip again clears it (teacher is optional).
class RunTeacherSelector extends StatelessWidget {
  final List<StaffModel> teachers;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const RunTeacherSelector({
    super.key,
    required this.teachers,
    required this.selectedId,
    required this.onSelected,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      return Text('assessment_run_no_teachers'.tr,
          style: context.typography.smRegular
              .copyWith(color: const Color(0xFF94A3B8)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in teachers) _chip(context, t),
      ],
    );
  }

  Widget _chip(BuildContext context, StaffModel t) {
    final id = t.uid;
    final selected = selectedId == id;
    return GestureDetector(
      onTap: () => onSelected(selected ? null : id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _accent : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          t.name,
          style: context.typography.smMedium.copyWith(
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
