import '../../../../../../index/index_main.dart';

/// Shown when the selected week has no attendance records at all — friendlier
/// than a blank screen.
class AttendanceReportEmpty extends StatelessWidget {
  const AttendanceReportEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40.h),
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      child: Column(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 60.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(
            'report_attendance_empty_title'.tr,
            textAlign: TextAlign.center,
            style: context.typography.mdMedium
                .copyWith(color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 6.h),
          Text(
            'report_attendance_empty_sub'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
