import '../../../../../index/index_main.dart';

class TicketCard extends StatelessWidget {
  final SupportTicketModel item;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TicketCard({super.key, required this.item, required this.onReply, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8.r, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(item.title, style: context.typography.displaySmBold.copyWith(fontSize: 14, color: const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)), child: Text('ticket_status_${item.status}'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 11, color: statusColor))),
            _TicketMenu(onReply: onReply, onEdit: onEdit, onDelete: onDelete),
          ]),
          SizedBox(height: 6.h),
          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF475569))),
          if (item.adminReply != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(8.r)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.reply_outlined, size: 14.sp, color: const Color(0xFF7C3AED)),
                SizedBox(width: 6.w),
                Expanded(child: Text(item.adminReply!, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.typography.smRegular.copyWith(fontSize: 12, color: const Color(0xFF7C3AED)))),
              ]),
            ),
          ],
          if (item.createdAt != null) ...[
            SizedBox(height: 6.h),
            Text(() { final d = DateTime.fromMillisecondsSinceEpoch(item.createdAt!); return '${d.day}/${d.month}/${d.year}'; }(), style: context.typography.smRegular.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ]),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return const Color(0xFF0EA5E9);
      case 'in_progress': return const Color(0xFFF59E0B);
      case 'resolved': return const Color(0xFF16A34A);
      default: return const Color(0xFF94A3B8);
    }
  }
}

class _TicketMenu extends StatelessWidget {
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TicketMenu({required this.onReply, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Act>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (a) {
      if (a == _Act.reply) onReply();
      if (a == _Act.edit) onEdit();
      if (a == _Act.delete) onDelete();
    },
    itemBuilder: (_) => [
      PopupMenuItem(value: _Act.reply, child: Row(children: [Icon(Icons.reply_outlined, size: 18.sp, color: const Color(0xFF7C3AED)), SizedBox(width: 10.w), Text('ticket_reply'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFF7C3AED)))])),
      PopupMenuItem(value: _Act.edit, child: Row(children: [Icon(Icons.edit_outlined, size: 18.sp, color: const Color(0xFF475569)), SizedBox(width: 10.w), Text('ticket_edit'.tr)])),
      PopupMenuItem(value: _Act.delete, child: Row(children: [Icon(Icons.delete_outline, size: 18.sp, color: const Color(0xFFDC2626)), SizedBox(width: 10.w), Text('ticket_delete'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626)))])),
    ],
  );
}

enum _Act { reply, edit, delete }
