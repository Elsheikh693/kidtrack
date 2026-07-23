import '../../index/index_main.dart';

/// Single-sheet state picker. Simple states record on one tap; a state that has
/// a classification expands inline to reveal its leaf options, and tapping a
/// leaf records immediately and closes — no second sheet, no confirm button.
class ChildStatePickerSheet extends StatefulWidget {
  const ChildStatePickerSheet({
    super.key,
    required this.currentId,
    required this.templates,
    required this.onPick,
  });

  final String currentId;
  final List<ChildStateTemplateModel> templates;
  final void Function(String stateId, String stateTitle) onPick;

  @override
  State<ChildStatePickerSheet> createState() => _ChildStatePickerSheetState();
}

class _ChildStatePickerSheetState extends State<ChildStatePickerSheet> {
  String? _expandedId;

  static const _green = Color(0xFF16A34A);
  static const _accent = Color(0xFF0891B2);

  void _pick(String id, String title) {
    Get.back();
    widget.onPick(id, title);
  }

  void _tapState(ChildStateTemplateModel? t, String id, String label) {
    if (t != null && t.options.isNotEmpty) {
      setState(() => _expandedId = _expandedId == id ? null : id);
    } else {
      _pick(id, label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'child_state_pick'.tr,
                style: context.typography.mdBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stateRow(
                      context,
                      id: kDefaultStateId,
                      label: 'child_state_default'.tr,
                      icon: Icons.groups_rounded,
                      expandable: false,
                      template: null,
                    ),
                    for (final t in widget.templates)
                      _stateRow(
                        context,
                        id: t.key ?? '',
                        label: t.title,
                        icon: ChildStateIcons.iconFor(t.icon),
                        expandable: t.options.isNotEmpty,
                        template: t,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateRow(
    BuildContext context, {
    required String id,
    required String label,
    required IconData icon,
    required bool expandable,
    required ChildStateTemplateModel? template,
  }) {
    final selected = widget.currentId == id;
    final expanded = _expandedId == id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: () => _tapState(template, id, label),
          leading: Icon(icon,
              size: 20, color: selected ? _green : const Color(0xFF64748B)),
          title: Text(
            label,
            style: context.typography.smMedium.copyWith(
              color: selected ? _green : const Color(0xFF1E293B),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          trailing: expandable
              ? AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(Icons.expand_more_rounded,
                      color: Color(0xFF94A3B8)),
                )
              : (selected
                  ? const Icon(Icons.check_circle_rounded,
                      color: _green, size: 20)
                  : null),
        ),
        if (expanded && template != null)
          _optionsBlock(context, template),
      ],
    );
  }

  Widget _optionsBlock(BuildContext context, ChildStateTemplateModel t) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final opt in t.options)
            if (opt.subOptions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _leafChip(
                  context,
                  opt.label,
                  () => _pick(t.key ?? '', '${t.title} — ${opt.label}'),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Text(
                  opt.label,
                  style: context.typography.xsMedium
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sub in opt.subOptions)
                    _leafChip(
                      context,
                      sub,
                      () => _pick(t.key ?? '', '${t.title} — $sub'),
                    ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  Widget _leafChip(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: context.typography.smMedium.copyWith(color: _accent),
        ),
      ),
    );
  }
}
