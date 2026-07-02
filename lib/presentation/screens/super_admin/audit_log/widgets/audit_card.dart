import '../../../../../index/index_main.dart';

class AuditCard extends StatelessWidget {
  final AuditLogModel item;
  const AuditCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final actionColor = _actionColor(item.action);
    final d = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8.r, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(children: [
          Container(width: 40.w, height: 40.h, decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(_actionIcon(item.action), size: 20.sp, color: actionColor)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.actorName, style: context.typography.smSemiBold.copyWith(fontSize: 14, color: const Color(0xFF1E293B)))),
              Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)), child: Text('audit_action_${item.action}'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 11, color: actionColor))),
            ]),
            SizedBox(height: 3.h),
            Text('audit_entity_${item.entity}'.tr, style: context.typography.smRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B))),
            if (item.description != null) ...[
              SizedBox(height: 2.h),
              Text(item.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.typography.smRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
            ],
            SizedBox(height: 3.h),
            Text('${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}', style: context.typography.smRegular.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
          ])),
        ]),
      ),
    );
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'create': return const Color(0xFF16A34A);
      case 'delete': return const Color(0xFFDC2626);
      default: return const Color(0xFFF59E0B);
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'create': return Icons.add_circle_outline;
      case 'delete': return Icons.delete_outline;
      default: return Icons.edit_outlined;
    }
  }
}
