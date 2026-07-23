import '../../../../../index/index_main.dart';

/// A single shift row on the shifts settings screen: name, its time window,
/// grace tolerance, active badge, and an edit/delete menu.
class ShiftCard extends StatelessWidget {
  final ShiftModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShiftCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        leading: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.schedule_rounded, color: color, size: 22.sp),
        ),
        title: Text(
          item.name,
          style: context.typography.smSemiBold
              .copyWith(color: const Color(0xFF1E293B)),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            children: [
              Text(
                '${item.startLabel} - ${item.endLabel}',
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF64748B)),
              ),
              SizedBox(width: 8.w),
              Text(
                'shifts_grace_badge'.trParams({'m': '${item.graceMinutes}'}),
                style: context.typography.xsMedium
                    .copyWith(fontSize: 11, color: color),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 16.sp, color: const Color(0xFF475569)),
                SizedBox(width: 8.w),
                Text('shifts_edit_action'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 16.sp, color: const Color(0xFFDC2626)),
                SizedBox(width: 8.w),
                Text('shifts_delete'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: const Color(0xFFDC2626))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
