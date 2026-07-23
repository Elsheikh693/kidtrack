import '../../../../../index/index_main.dart';

/// "Needs evaluation?" toggle row for the child-state editor.
class ChildStateClassificationToggle extends StatelessWidget {
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const ChildStateClassificationToggle({
    super.key,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'child_state_needs_classification'.tr,
                style: context.typography.smMedium
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Text(
                'child_state_needs_classification_hint'.tr,
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          activeTrackColor: accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
