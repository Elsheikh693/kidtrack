import '../../../../../index/index_main.dart';

/// Editor card for one top-level classification option: its label plus the
/// list of level-2 sub-option fields. Controllers are owned by the parent
/// [StateClassificationEditor]; this card only wires them to the UI.
class StateOptionEditorCard extends StatelessWidget {
  final TextEditingController labelController;
  final List<TextEditingController> subControllers;

  /// Called on every text edit so the parent can re-emit the current options.
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final VoidCallback onAddSub;
  final ValueChanged<int> onRemoveSub;

  const StateOptionEditorCard({
    super.key,
    required this.labelController,
    required this.subControllers,
    required this.onChanged,
    required this.onRemove,
    required this.onAddSub,
    required this.onRemoveSub,
  });

  static const _accent = Color(0xFF0891B2);
  static const _border = Color(0xFFE2E8F0);
  static const _fill = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniField(
                  controller: labelController,
                  hint: 'child_state_option_hint'.tr,
                  bold: true,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 6),
              _IconAction(
                icon: Icons.close_rounded,
                color: const Color(0xFFDC2626),
                onTap: onRemove,
              ),
            ],
          ),
          for (int j = 0; j < subControllers.length; j++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.subdirectory_arrow_left_rounded,
                      size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MiniField(
                      controller: subControllers[j],
                      hint: 'child_state_suboption_hint'.tr,
                      bold: false,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.remove_circle_outline_rounded,
                    color: const Color(0xFF94A3B8),
                    onTap: () => onRemoveSub(j),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onAddSub,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                foregroundColor: _accent,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                'child_state_add_suboption'.tr,
                style: context.typography.xsMedium.copyWith(color: _accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool bold;
  final VoidCallback onChanged;

  const _MiniField({
    required this.controller,
    required this.hint,
    required this.bold,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.next,
      style: (bold
              ? context.typography.smSemiBold
              : context.typography.smRegular)
          .copyWith(color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF0891B2)),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
