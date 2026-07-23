import '../../../../../index/index_main.dart';

class CdAssignTeacherSheet extends StatelessWidget {
  final List<StaffModel> available;
  final Function(StaffModel) onAssign;

  const CdAssignTeacherSheet({
    super.key,
    required this.available,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            _Title(),
            const Divider(height: 1),
            available.isEmpty
                ? _EmptyState()
                : Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (_, i) => _StaffTile(
                        staff: available[i],
                        onTap: () => onAssign(available[i]),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
    child: Text(
      'cd_assign_teacher_title'.tr,
      style: context.typography.mdBold.copyWith(
        fontSize: 17,
        color: const Color(0xFF1E293B),
      ),
    ),
  );
}

class _StaffTile extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;

  const _StaffTile({required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: context.typography.mdBold.copyWith(
                    color: const Color(0xFF7C3AED),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    staff.role.name.tr,
                    style: context.typography.smRegular.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: const Color(0xFF7C3AED),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 40.h),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.person_off_outlined, size: 48.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 12.h),
          Text(
            'cd_assign_teacher_empty'.tr,
            style: context.typography.smRegular.copyWith(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    ),
  );
}
