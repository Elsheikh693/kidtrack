import '../../../../../index/index_main.dart';

class EvalButton extends StatelessWidget {
  const EvalButton({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final EvalLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (level) {
        EvalLevel.excellent => Icons.star_rounded,
        EvalLevel.needsFollow => Icons.remove_red_eye_rounded,
        EvalLevel.needsAttention => Icons.report_problem_rounded,
      };

  String get _labelKey => switch (level) {
        EvalLevel.excellent => 'teacher_eval_excellent',
        EvalLevel.needsFollow => 'teacher_eval_needs_follow',
        EvalLevel.needsAttention => 'teacher_eval_needs_attention',
      };

  Color get _color => switch (level) {
        EvalLevel.excellent => AppColors.activityGreen,
        EvalLevel.needsFollow => AppColors.activityAmber,
        EvalLevel.needsAttention => AppColors.activityRed,
      };

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? _color : _color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _color : _color.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 20, color: isSelected ? Colors.white : _color),
              const SizedBox(height: 3),
              Text(
                _labelKey.tr,
                style: context.typography.xsMedium.copyWith(
                  color: isSelected ? Colors.white : _color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
