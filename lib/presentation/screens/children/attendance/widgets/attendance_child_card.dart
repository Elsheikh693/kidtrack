import '../../../../../index/index_main.dart';

class AttendanceChildCard extends StatelessWidget {
  final ChildAttendanceModel item;
  final String childName;
  final String branchName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AttendanceChildCard({
    super.key,
    required this.item,
    required this.childName,
    required this.branchName,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (item.status) {
      case 'present': return const Color(0xFF16A34A);
      case 'late': return const Color(0xFFD97706);
      case 'excused': return const Color(0xFF0284C7);
      default: return const Color(0xFFDC2626);
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'present': return const Color(0xFFDCFCE7);
      case 'late': return const Color(0xFFFEF3C7);
      case 'excused': return const Color(0xFFE0F2FE);
      default: return const Color(0xFFFEE2E2);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case 'present': return 'checkin_status_present'.tr;
      case 'late': return 'checkin_status_late'.tr;
      case 'excused': return 'checkin_status_excused'.tr;
      default: return 'checkin_status_absent'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.child_care, color: _statusColor, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          childName,
                          style: context.typography.smSemiBold.copyWith(
                            fontSize: 15,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _statusLabel,
                          style: context.typography.smSemiBold.copyWith(
                            fontSize: 11,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.date,
                        style: context.typography.xsRegular.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.location_on_outlined,
                        size: 13.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          branchName,
                          style: context.typography.xsRegular.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _AttendanceMenu(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _AttendanceMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AttendanceMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Act>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (a) {
      if (a == _Act.edit) onEdit();
      if (a == _Act.delete) onDelete();
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _Act.edit,
        child: Row(children: [
          Icon(Icons.edit_outlined, size: 18.sp, color: const Color(0xFF475569)),
          SizedBox(width: 10.w),
          Text('checkin_edit'.tr, style: context.typography.smRegular.copyWith(fontSize: 14)),
        ]),
      ),
      PopupMenuItem(
        value: _Act.delete,
        child: Row(children: [
          Icon(Icons.delete_outline, size: 18.sp, color: const Color(0xFFDC2626)),
          SizedBox(width: 10.w),
          Text(
            'checkin_delete'.tr,
            style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFFDC2626)),
          ),
        ]),
      ),
    ],
  );
}

enum _Act { edit, delete }
