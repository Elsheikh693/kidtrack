import '../../../../../index/index_main.dart';

class EvalSectionHeader extends StatelessWidget {
  const EvalSectionHeader({
    super.key,
    required this.total,
    required this.evaluated,
    required this.unevaluated,
    required this.progress,
  });

  final int total;
  final int evaluated;
  final int unevaluated;
  final double progress;

  static const _kGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'teacheract32_eval_students'.tr,
              style: context.typography.mdBold.copyWith(color: const Color(0xFF1F2937)),
            ),
            const Spacer(),
            if (unevaluated > 0)
              _Badge(
                label: '$unevaluated ${'teacheract32_not_evaluated_suffix'.tr}',
                color: const Color(0xFFD97706),
                bg: Colors.orange.withValues(alpha: 0.1),
              )
            else if (total > 0)
              _Badge(
                label: 'teacheract32_eval_done'.tr,
                color: _kGreen,
                bg: _kGreen.withValues(alpha: 0.1),
                icon: Icons.check_circle_rounded,
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_kGreen),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.bg, this.icon});
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, color: color, size: 13), const SizedBox(width: 4)],
          Text(label, style: context.typography.xsMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
