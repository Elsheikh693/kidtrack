import '../../../../../index/index_main.dart';

/// Score (0–5) selector for the eval-level editor. The score feeds report
/// averages, so higher = better performance.
class EvalLevelScoreSelector extends StatelessWidget {
  final double score;
  final Color accent;
  final ValueChanged<double> onChanged;

  const EvalLevelScoreSelector({
    super.key,
    required this.score,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'eval_level_label_score'.tr,
              style: context.typography.xsMedium
                  .copyWith(color: const Color(0xFF374151)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_fmt(score)}/5',
                style: context.typography.smSemiBold.copyWith(color: accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'eval_level_score_hint'.tr,
          style: context.typography.xsRegular
              .copyWith(color: const Color(0xFF94A3B8)),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            inactiveTrackColor: accent.withValues(alpha: 0.15),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: score,
            min: 0,
            max: 5,
            divisions: 10,
            label: _fmt(score),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
