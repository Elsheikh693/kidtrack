import '../../../../../index/index_main.dart';

class CdHeader extends StatelessWidget {
  final ClassroomModel classroom;
  final int childCount;
  final int teacherCount;

  const CdHeader({
    super.key,
    required this.classroom,
    required this.childCount,
    required this.teacherCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.class_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classroom.name,
                      style: context.typography.lgBold.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    if (!classroom.isActive)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'classroom_inactive'.tr,
                          style: context.typography.smSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _StatChip(
                icon: Icons.child_care_rounded,
                value: childCount.toString(),
                label: 'cd_stat_children'.tr,
              ),
              SizedBox(width: 12.w),
              _StatChip(
                icon: Icons.people_rounded,
                value: classroom.capacity != null
                    ? '$childCount / ${classroom.capacity}'
                    : '$childCount',
                label: 'cd_stat_capacity'.tr,
              ),
              SizedBox(width: 12.w),
              _StatChip(
                icon: Icons.school_rounded,
                value: teacherCount.toString(),
                label: 'cd_stat_teachers'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(height: 4.h),
            Text(
              value,
              style: context.typography.mdBold.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: context.typography.xsRegular.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
