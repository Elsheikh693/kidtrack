import '../../../../../index/index_main.dart';

/// Class-level one-tap actions above the child list: apply a persistent status
/// to the whole class ("الكل نام" at nap time) or return everyone to the class.
/// Controller-agnostic so both the daily states sheet and the activity screen
/// reuse it. Only STATUS templates are offered (events stay per-child).
class ClassBulkActionsBar extends StatelessWidget {
  const ClassBulkActionsBar({
    super.key,
    required this.statuses,
    required this.onApply,
    required this.onReturnAll,
  });

  final List<ChildStateTemplateModel> statuses;
  final void Function(String stateId, String stateTitle) onApply;
  final VoidCallback onReturnAll;

  static const _accent = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'child_state_bulk_label'.tr,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 8),
          for (final t in statuses) ...[
            _chip(
              context,
              icon: ChildStateIcons.iconFor(t.icon),
              label: t.title,
              onTap: () => onApply(t.key ?? '', t.title),
            ),
            const SizedBox(width: 8),
          ],
          _chip(
            context,
            icon: Icons.groups_rounded,
            label: 'child_state_back_to_class'.tr,
            onTap: onReturnAll,
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    final color = accent ? _accent : const Color(0xFF475569);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: accent
              ? _accent.withValues(alpha: 0.08)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: accent
                ? _accent.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "show / hide the normal children" toggle row shown at the end of the
/// list — normal kids are folded away by default so exceptions stand out.
class ExpandNormalTile extends StatelessWidget {
  const ExpandNormalTile({
    super.key,
    required this.hidden,
    required this.expanded,
    required this.onTap,
  });

  final int hidden;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = expanded
        ? 'child_state_hide_normal'.tr
        : 'child_state_show_normal'.trParams({'count': '$hidden'});
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.typography.smMedium
                  .copyWith(color: const Color(0xFF64748B)),
            ),
            const SizedBox(width: 4),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
