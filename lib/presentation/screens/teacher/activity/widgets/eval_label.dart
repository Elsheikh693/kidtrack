import '../../../../../index/index_main.dart';

class EvalLabel extends StatelessWidget {
  const EvalLabel({super.key, required this.level});
  final EvalLevel level;

  @override
  Widget build(BuildContext context) {
    final (labelKey, color) = switch (level) {
      EvalLevel.excellent => ('teacher_eval_excellent', AppColors.activityGreen),
      EvalLevel.needsFollow => ('teacher_eval_needs_follow', AppColors.activityAmber),
      EvalLevel.needsAttention => ('teacher_eval_needs_attention', AppColors.activityRed),
    };
    return Text(
      labelKey.tr,
      style: context.typography.xsMedium.copyWith(color: color),
    );
  }
}
