import '../../../../../index/index_main.dart';

/// Icon-grid selector for the eval-level editor.
class EvalLevelIconPicker extends StatelessWidget {
  final String selected;
  final Color accent;
  final ValueChanged<String> onSelected;

  const EvalLevelIconPicker({
    super.key,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'eval_level_label_icon'.tr,
          style: context.typography.xsMedium
              .copyWith(color: const Color(0xFF374151)),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EvalLevelIcons.presets.map((preset) {
            final isSelected = selected == preset.key;
            return GestureDetector(
              onTap: () => onSelected(preset.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.12)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? accent : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    preset.icon,
                    size: 22,
                    color: isSelected ? accent : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
