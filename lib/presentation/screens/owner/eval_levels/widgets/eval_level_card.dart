import '../../../../../index/index_main.dart';

class EvalLevelCard extends StatelessWidget {
  final EvalLevelTemplateModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const EvalLevelCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(item.color);
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
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              EvalLevelIcons.iconFor(item.icon),
              size: 22,
              color: color,
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
          child: Row(
            children: [
              // Score chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: color),
                    const SizedBox(width: 3),
                    Text(
                      '${'eval_level_score'.tr} ${_fmt(item.score)}/5',
                      style: context.typography.xsMedium.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Active state chip
              Container(
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
                      ? 'eval_level_active'.tr
                      : 'eval_level_inactive'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: item.isActive
                        ? AppColors.activityGreen
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
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
                Text('eval_level_edit_action'.tr),
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
                      ? 'eval_level_toggle_inactive'.tr
                      : 'eval_level_toggle_active'.tr,
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
                  'eval_level_delete'.tr,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
