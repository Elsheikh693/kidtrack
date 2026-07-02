import '../../../../../index/index_main.dart';

class EnrollmentCard extends StatelessWidget {
  final EnrollmentModel enrollment;
  final String childName;
  final String branchName;
  final String classroomName;
  final String statusLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EnrollmentCard({
    super.key,
    required this.enrollment,
    required this.childName,
    required this.branchName,
    required this.classroomName,
    required this.statusLabel,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (enrollment.status) {
      case 'enrolled': return Colors.green;
      case 'withdrawn': return Colors.red;
      case 'graduated': return Colors.blue;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                  decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.school_outlined, color: const Color(0xFF6366F1), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(childName, style: context.typography.mdBold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                      Text(branchName, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(statusLabel, style: context.typography.smSemiBold.copyWith(fontSize: 12, color: _statusColor)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 10.h),
            Row(
              children: [
                _InfoItem(icon: Icons.meeting_room_outlined, text: classroomName),
                SizedBox(width: 16.w),
                if (enrollment.startDate != null)
                  _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(enrollment.startDate!),
                  ),
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

  String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14.sp, color: const Color(0xFF94A3B8)),
      SizedBox(width: 4.w),
      Text(text, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
    ],
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(padding: EdgeInsets.all(6.w), child: Icon(icon, size: 20.sp, color: color)),
  );
}
