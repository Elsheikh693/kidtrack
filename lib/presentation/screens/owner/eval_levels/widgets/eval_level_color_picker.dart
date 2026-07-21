import '../../../../../index/index_main.dart';

/// Color swatch selector for the eval-level editor.
class EvalLevelColorPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const EvalLevelColorPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'eval_level_label_color'.tr,
          style: context.typography.xsMedium
              .copyWith(color: const Color(0xFF374151)),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: EvalLevelPalette.presets.map((value) {
            final isSelected = selected == value;
            final color = Color(value);
            return GestureDetector(
              onTap: () => onSelected(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isSelected ? 0.5 : 0.2),
                      blurRadius: isSelected ? 10 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
