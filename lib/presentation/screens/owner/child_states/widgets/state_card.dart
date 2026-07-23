import '../../../../../index/index_main.dart';

class StateCard extends StatelessWidget {
  final ChildStateTemplateModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const StateCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              ChildStateIcons.iconFor(item.icon),
              size: 22,
              color: _accent,
            ),
          ),
        ),
        title: Text(
          item.title,
          style: context.typography.smSemiBold
              .copyWith(color: const Color(0xFF1E293B)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: item.isActive
                  ? AppColors.activityGreen.withValues(alpha: 0.08)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.isActive
                  ? 'child_state_active'.tr
                  : 'child_state_inactive'.tr,
              style: context.typography.xsMedium.copyWith(
                color: item.isActive
                    ? AppColors.activityGreen
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'toggle') onToggle();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                const Icon(Icons.edit_outlined,
                    size: 16, color: Color(0xFF475569)),
                const SizedBox(width: 8),
                Text('child_state_edit_action'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(children: [
                Icon(
                  item.isActive
                      ? Icons.toggle_off_outlined
                      : Icons.toggle_on_outlined,
                  size: 16,
                  color: item.isActive
                      ? const Color(0xFF94A3B8)
                      : AppColors.activityGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  item.isActive
                      ? 'child_state_toggle_inactive'.tr
                      : 'child_state_toggle_active'.tr,
                ),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_outline,
                    size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Text(
                  'child_state_delete'.tr,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
