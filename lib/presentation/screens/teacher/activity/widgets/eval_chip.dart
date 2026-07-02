import '../../../../../index/index_main.dart';

class EvalChip extends StatelessWidget {
  const EvalChip({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: context.typography.xsMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
