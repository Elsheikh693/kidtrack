import '../../../../../index/index_main.dart';

class EndEvalButton extends StatelessWidget {
  const EndEvalButton({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final EvalLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  static const _data = {
    EvalLevel.excellent: (
      'teacher_eval_excellent',
      '🟢',
      AppColors.activityGreen
    ),
    EvalLevel.needsFollow: (
      'teacher_eval_follow_short',
      '🟡',
      AppColors.activityAmber
    ),
    EvalLevel.needsAttention: (
      'teacher_eval_attention_short',
      '🔴',
      AppColors.activityRed
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (labelKey, emoji, color) = _data[level]!;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: context.typography.smMedium),
              const SizedBox(height: 2),
              Text(
                labelKey.tr,
                style: context.typography.xsMedium.copyWith(
                  color: isSelected ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
