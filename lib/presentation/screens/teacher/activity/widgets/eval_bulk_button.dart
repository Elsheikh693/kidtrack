import '../../../../../index/index_main.dart';

class EvalBulkButton extends StatelessWidget {
  const EvalBulkButton({
    super.key,
    required this.icon,
    required this.labelKey,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String labelKey;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.07) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  active ? color.withValues(alpha: 0.25) : Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: active ? color : Colors.grey.shade400),
              const SizedBox(height: 4),
              Text(
                labelKey.tr,
                style: context.typography.xsMedium.copyWith(
                  color: active ? color : Colors.grey.shade400,
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
