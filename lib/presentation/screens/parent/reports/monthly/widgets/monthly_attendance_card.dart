import '../../../../../../index/index_main.dart';

/// Monthly attendance breakdown: a segmented bar of present / late / absent
/// days with a legend. (The headline rate lives in the hero card.)
class MonthlyAttendanceCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyAttendanceCard({super.key, required this.controller});

  static const _present = Color(0xFF16A34A);
  static const _late = Color(0xFFD97706);
  static const _absent = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final present = controller.presentCount.value;
      final late = controller.lateCount.value;
      final absent = controller.absentCount.value;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available_rounded,
                    color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text('report_attendance_title'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
                const Spacer(),
                Text(
                  'report_monthly_school_days'
                      .trParams({'n': '${controller.schoolDays.value}'}),
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SizedBox(
                height: 10.h,
                child: Row(
                  children: [
                    if (present > 0)
                      Expanded(flex: present, child: Container(color: _present)),
                    if (late > 0)
                      Expanded(flex: late, child: Container(color: _late)),
                    if (absent > 0)
                      Expanded(flex: absent, child: Container(color: _absent)),
                    if (present + late + absent == 0)
                      Expanded(
                          child: Container(color: const Color(0xFFE2E8F0))),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _Stat(
                    label: 'report_status_present',
                    value: present,
                    color: _present),
                _Stat(label: 'report_status_late', value: late, color: _late),
                _Stat(
                    label: 'report_status_absent',
                    value: absent,
                    color: _absent),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text('$value',
              style: context.typography.smSemiBold.copyWith(color: color)),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(label.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsRegular
                    .copyWith(fontSize: 10, color: const Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }
}
