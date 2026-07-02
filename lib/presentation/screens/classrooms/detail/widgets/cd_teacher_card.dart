import '../../../../../index/index_main.dart';

class CdTeacherCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onRemove;

  const CdTeacherCard({
    super.key,
    required this.staff,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _TeacherAvatar(name: staff.name),
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
                SizedBox(height: 3.h),
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
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              color: const Color(0xFFDC2626),
              size: 22.sp,
            ),
            tooltip: 'cd_remove_teacher'.tr,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String name;
  const _TeacherAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          initial,
          style: context.typography.mdBold.copyWith(
            color: const Color(0xFF7C3AED),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
