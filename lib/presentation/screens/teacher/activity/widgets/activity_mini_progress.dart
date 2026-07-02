import '../../../../../index/index_main.dart';

class ActivityMiniProgress extends StatelessWidget {
  const ActivityMiniProgress({
    super.key,
    required this.evaluated,
    required this.total,
  });
  final int evaluated;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$evaluated / $total',
        style: context.typography.xsMedium.copyWith(color: AppColors.white),
      ),
    );
  }
}
