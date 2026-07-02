import '../../../../../index/index_main.dart';

class EndBulkButton extends StatelessWidget {
  const EndBulkButton({
    super.key,
    required this.emoji,
    required this.labelKey,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String labelKey;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: context.typography.lgBold),
              const SizedBox(height: 2),
              Text(
                labelKey.tr,
                style: context.typography.xsMedium.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
