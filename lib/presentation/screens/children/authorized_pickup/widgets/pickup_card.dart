import '../../../../../index/index_main.dart';

class PickupCard extends StatelessWidget {
  final AuthorizedPickupModel pickup;
  final String childName;
  final String relationshipLabel;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const PickupCard({super.key, required this.pickup, required this.childName, required this.relationshipLabel, required this.onEdit, required this.onToggleActive, required this.onDelete});

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
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.person_outlined, color: const Color(0xFFF59E0B), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickup.name, style: context.typography.mdBold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                      Text('$relationshipLabel • $childName', style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: (pickup.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(pickup.isActive ? 'common_active'.tr : 'common_inactive'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 11, color: pickup.isActive ? Colors.green : Colors.grey)),
                ),
              ],
            ),
            if (pickup.phone != null) ...[
              SizedBox(height: 8.h),
              Row(children: [
                Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 4.w),
                Text(pickup.phone!, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                if (!pickup.isPermanent) ...[
                  SizedBox(width: 12.w),
                  Icon(Icons.access_time_outlined, size: 14.sp, color: const Color(0xFFF59E0B)),
                  SizedBox(width: 4.w),
                  Text('pickup_temporary'.tr, style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFFF59E0B))),
                ],
              ]),
            ],
            SizedBox(height: 8.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionBtn(icon: pickup.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, color: pickup.isActive ? Colors.green : Colors.grey, onTap: onToggleActive),
                SizedBox(width: 4.w),
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
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(padding: EdgeInsets.all(6.w), child: Icon(icon, size: 20.sp, color: color)),
  );
}
