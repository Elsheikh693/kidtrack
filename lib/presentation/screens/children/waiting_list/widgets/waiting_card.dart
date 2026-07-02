import '../../../../../index/index_main.dart';

class WaitingCard extends StatelessWidget {
  final WaitingListModel waiting;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WaitingCard({super.key, required this.waiting, required this.statusLabel, required this.statusColor, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8.r, offset: Offset(0, 2.h))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w, height: 44.h,
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.hourglass_empty_rounded, color: const Color(0xFF8B5CF6), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(waiting.childName, style: context.typography.mdBold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                      Text(waiting.parentName, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(statusLabel, style: context.typography.smSemiBold.copyWith(fontSize: 12, color: statusColor)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 4.w),
                Text(waiting.parentPhone, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                if (waiting.notes != null) ...[
                  SizedBox(width: 12.w),
                  Icon(Icons.notes_outlined, size: 14.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Expanded(child: Text(waiting.notes!, style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)), overflow: TextOverflow.ellipsis)),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionBtn(icon: Icons.edit_outlined, color: const Color(0xFF6366F1), onTap: onEdit),
                SizedBox(width: 4.w),
                _ActionBtn(icon: Icons.delete_outline_rounded, color: Colors.red, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 20, color: color)),
  );
}
