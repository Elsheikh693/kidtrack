import '../../../../../index/index_main.dart';

class EndProgressChip extends StatelessWidget {
  const EndProgressChip({
    super.key,
    required this.evaluated,
    required this.total,
  });

  final int evaluated;
  final int total;

  @override
  Widget build(BuildContext context) {
    final allDone = total > 0 && evaluated >= total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: allDone
            ? AppColors.activityGreen.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$evaluated / $total',
        style: context.typography.xsMedium.copyWith(
          color: allDone ? AppColors.activityGreen : Colors.grey.shade600,
        ),
      ),
    );
  }
}
