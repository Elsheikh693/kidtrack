import '../../../../../index/index_main.dart';

class NurseryCard extends StatelessWidget {
  final NurseryModel nursery;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onOpenOwners;

  const NurseryCard({
    super.key,
    required this.nursery,
    required this.onToggleActive,
    required this.onDelete,
    required this.onOpenOwners,
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
            color: Colors.black.withValues(alpha: 0.05),
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
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.home_work_rounded, color: const Color(0xFF6366F1), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nursery.name,
                        style: context.typography.mdBold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (nursery.address != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          nursery.address!,
                          style: context.typography.xsRegular.copyWith(color: const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusChip(isActive: nursery.isActive),
              ],
            ),
            if (nursery.phone != null || nursery.email != null) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 12.h),
              Row(
                children: [
                  if (nursery.phone != null)
                    _InfoChip(icon: Icons.phone_outlined, text: nursery.phone!),
                  if (nursery.phone != null && nursery.email != null)
                    SizedBox(width: 8.w),
                  if (nursery.email != null)
                    Expanded(
                      child: _InfoChip(icon: Icons.email_outlined, text: nursery.email!),
                    ),
                ],
              ),
            ],
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 8.h),
            Row(
              children: [
                _OwnersChip(count: nursery.ownerCount, onTap: onOpenOwners),
                const Spacer(),
                _ActionBtn(
                  icon: nursery.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                  color: nursery.isActive ? Colors.green : Colors.grey,
                  onTap: onToggleActive,
                ),
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

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      isActive ? 'common_active'.tr : 'common_inactive'.tr,
      style: context.typography.smSemiBold.copyWith(
        fontSize: 12,
        color: isActive ? Colors.green : Colors.grey,
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14.sp, color: const Color(0xFF94A3B8)),
      SizedBox(width: 4.w),
      Flexible(
        child: Text(
          text,
          style: context.typography.xsRegular.copyWith(color: const Color(0xFF64748B)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _OwnersChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _OwnersChip({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 15.sp, color: const Color(0xFF6366F1)),
          SizedBox(width: 5.w),
          Text(
            '${'nursery_owners_count'.tr}: $count',
            style: context.typography.smSemiBold.copyWith(
              fontSize: 12,
              color: const Color(0xFF6366F1),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_left_rounded, size: 18.sp, color: const Color(0xFF6366F1)),
        ],
      ),
    ),
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
    child: Padding(
      padding: EdgeInsets.all(6.w),
      child: Icon(icon, size: 20.sp, color: color),
    ),
  );
}
