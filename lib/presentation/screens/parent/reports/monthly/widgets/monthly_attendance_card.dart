import '../../../../../../index/index_main.dart';

/// Monthly attendance summary: the rate with a colored ring and a
/// present/late/absent breakdown.
class MonthlyAttendanceCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyAttendanceCard({super.key, required this.controller});

  Color _rateColor(int rate) {
    if (rate >= 90) return const Color(0xFF16A34A);
    if (rate >= 75) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rate = controller.attendanceRate.value;
      final color = _rateColor(rate);
      return Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
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
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                SizedBox(
                  width: 66.w,
                  height: 66.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 66.w,
                        height: 66.w,
                        child: CircularProgressIndicator(
                          value: rate / 100,
                          strokeWidth: 7.w,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('$rate%',
                          style: context.typography.smSemiBold
                              .copyWith(color: color)),
                    ],
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Row(
                    children: [
                      _Stat(
                          label: 'report_status_present',
                          value: controller.presentCount.value,
                          color: const Color(0xFF16A34A)),
                      _Stat(
                          label: 'report_status_late',
                          value: controller.lateCount.value,
                          color: const Color(0xFFD97706)),
                      _Stat(
                          label: 'report_status_absent',
                          value: controller.absentCount.value,
                          color: const Color(0xFFDC2626)),
                    ],
                  ),
                ),
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
      child: Column(
        children: [
          Text('$value',
              style: context.typography.lgBold.copyWith(color: color)),
          SizedBox(height: 2.h),
          Text(label.tr,
              textAlign: TextAlign.center,
              style: context.typography.xsRegular
                  .copyWith(fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
