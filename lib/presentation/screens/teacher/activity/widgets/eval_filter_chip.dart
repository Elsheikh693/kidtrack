import '../../../../../index/index_main.dart';

class EvalFilterChip extends StatelessWidget {
  const EvalFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: context.typography.xsMedium.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
