import '../../../../../index/index_main.dart';

class DailyCareCard extends StatelessWidget {
  final DailyCareLogModel item;
  final String childName;
  final String classroomName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DailyCareCard({
    super.key,
    required this.item,
    required this.childName,
    required this.classroomName,
    required this.onEdit,
    required this.onDelete,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.child_friendly,
                    color: const Color(0xFF16A34A),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childName,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        item.date,
                        style: context.typography.xsRegular.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                _DailyCareMenu(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (item.mood != null)
                  _InfoChip(
                    icon: Icons.mood,
                    label: 'care_mood_${item.mood}'.tr,
                    color: const Color(0xFF7C3AED),
                  ),
                _InfoChip(
                  icon: Icons.wc,
                  label: '${item.bathroomCount}x',
                  color: const Color(0xFF0284C7),
                ),
                if (item.diaperChanges > 0)
                  _InfoChip(
                    icon: Icons.baby_changing_station,
                    label: '${item.diaperChanges}x',
                    color: const Color(0xFFD97706),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: context.typography.xsMedium.copyWith(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _DailyCareMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _DailyCareMenu({required this.onEdit, required this.onDelete});

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
          Text('care_edit_title'.tr, style: context.typography.smRegular.copyWith(fontSize: 14)),
        ]),
      ),
      PopupMenuItem(
        value: _Act.delete,
        child: Row(children: [
          Icon(Icons.delete_outline, size: 18.sp, color: const Color(0xFFDC2626)),
          SizedBox(width: 10.w),
          Text(
            'care_delete'.tr,
            style: context.typography.smRegular.copyWith(fontSize: 14, color: const Color(0xFFDC2626)),
          ),
        ]),
      ),
    ],
  );
}

enum _Act { edit, delete }
