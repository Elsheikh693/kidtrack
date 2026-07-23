import '../../../../../index/index_main.dart';

/// Live preview of the state's icon + title as it will appear to teachers.
class ChildStatePreviewTile extends StatelessWidget {
  final TextEditingController controller;
  final String icon;
  final Color accent;

  const ChildStatePreviewTile({
    super.key,
    required this.controller,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isEmpty = controller.text.isEmpty;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(ChildStateIcons.iconFor(icon), size: 28, color: accent),
              const SizedBox(width: 12),
              Text(
                isEmpty ? 'child_state_label_title_hint'.tr : controller.text,
                style: context.typography.mdBold.copyWith(
                  color: isEmpty
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
