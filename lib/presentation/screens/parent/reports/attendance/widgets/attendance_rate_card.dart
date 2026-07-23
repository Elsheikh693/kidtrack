import '../../../../../../index/index_main.dart';
import 'attendance_status.dart';

/// Hero card: the attendance rate as a big circular gauge with its qualitative
/// label, then a compact present/late/absent breakdown underneath.
class AttendanceRateCard extends StatelessWidget {
  final WeeklyAttendanceController controller;
  const AttendanceRateCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rate = controller.rate.value;
      final color = AttendanceStatus.rateColor(rate);
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: 132.w,
              height: 132.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 132.w,
                    height: 132.w,
                    child: CircularProgressIndicator(
                      value: rate / 100,
                      strokeWidth: 11.w,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$rate%',
                          style: context.typography.xlBold
                              .copyWith(color: color)),
                      Text('report_attendance_rate'.tr,
                          style: context.typography.xsRegular
                              .copyWith(color: const Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                AttendanceStatus.rateLabelKey(rate).tr,
                style: context.typography.smSemiBold.copyWith(color: color),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _Breakdown(
                  labelKey: 'report_status_present',
                  value: controller.presentCount.value,
                  color: AttendanceStatus.present,
                ),
                _Breakdown(
                  labelKey: 'report_status_late',
                  value: controller.lateCount.value,
                  color: AttendanceStatus.late,
                ),
                _Breakdown(
                  labelKey: 'report_status_absent',
                  value: controller.absentCount.value,
                  color: AttendanceStatus.absent,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Breakdown extends StatelessWidget {
  final String labelKey;
  final int value;
  final Color color;
  const _Breakdown(
      {required this.labelKey, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: context.typography.lgBold.copyWith(color: color)),
          SizedBox(height: 2.h),
          Text(labelKey.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
