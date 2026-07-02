import '../../../../../index/index_main.dart';

class ActivityChip extends StatelessWidget {
  const ActivityChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
