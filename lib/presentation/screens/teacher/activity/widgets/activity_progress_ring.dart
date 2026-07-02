import '../../../../../index/index_main.dart';

class ActivityProgressRing extends StatelessWidget {
  const ActivityProgressRing({
    super.key,
    required this.progress,
    required this.evaluated,
    required this.total,
  });
  final double progress;
  final int evaluated;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.activityGreenAccent),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  '$evaluated/$total',
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
