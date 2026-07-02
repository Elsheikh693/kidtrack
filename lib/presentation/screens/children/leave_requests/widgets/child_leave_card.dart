import '../../../../../index/index_main.dart';

class ChildLeaveCard extends StatelessWidget {
  final ChildLeaveRequestModel item;
  final String childName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ChildLeaveCard({
    super.key,
    required this.item,
    required this.childName,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
  });

  Color get _statusColor {
    switch (item.status) {
      case 'approved': return const Color(0xFF16A34A);
      case 'rejected': return const Color(0xFFDC2626);
      default: return const Color(0xFFD97706);
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'approved': return const Color(0xFFDCFCE7);
      case 'rejected': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFFEF3C7);
    }
  }

  String get _statusLabel => 'child_leave_status_${item.status}'.tr;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.fromMillisecondsSinceEpoch(item.startDate);
    final end = DateTime.fromMillisecondsSinceEpoch(item.endDate);
    final fmt = (DateTime d) =>
        '${d.day}/${d.month}/${d.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    childName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _LeaveMenu(
                  isPending: item.status == 'pending',
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onApprove: onApprove,
                  onReject: onReject,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.date_range_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  '${fmt(start)} - ${fmt(end)}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            if (item.reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.reason,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaveMenu extends StatelessWidget {
  final bool isPending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LeaveMenu({
    required this.isPending,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Act>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (a) {
      switch (a) {
        case _Act.approve: onApprove();
        case _Act.reject: onReject();
        case _Act.edit: onEdit();
        case _Act.delete: onDelete();
      }
    },
    itemBuilder: (_) => [
      if (isPending) ...[
        PopupMenuItem(
          value: _Act.approve,
          child: Row(children: [
            const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF16A34A)),
            const SizedBox(width: 10),
            Text('child_leave_approve'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFF16A34A))),
          ]),
        ),
        PopupMenuItem(
          value: _Act.reject,
          child: Row(children: [
            const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFDC2626)),
            const SizedBox(width: 10),
            Text('child_leave_reject'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFFDC2626))),
          ]),
        ),
      ],
      PopupMenuItem(
        value: _Act.edit,
        child: Row(children: [
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
          const SizedBox(width: 10),
          Text('child_leave_edit'.tr, style: const TextStyle(fontSize: 14)),
        ]),
      ),
      PopupMenuItem(
        value: _Act.delete,
        child: Row(children: [
          const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Text('child_leave_delete'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFFDC2626))),
        ]),
      ),
    ],
  );
}

enum _Act { approve, reject, edit, delete }
