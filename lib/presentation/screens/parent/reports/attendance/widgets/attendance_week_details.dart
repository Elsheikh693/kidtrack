import '../../../../../../index/index_main.dart';
import 'attendance_status.dart';

/// The week as a plain list — day, status pill, and check-in time — divided by
/// thin separators. Upcoming and unrecorded days show a dash for the time.
class AttendanceWeekDetails extends StatelessWidget {
  final WeeklyAttendanceController controller;
  const AttendanceWeekDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
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
      child: Obx(() {
        final days = controller.days;
        return Column(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              _DetailRow(
                dayKey: days[i].dayKey,
                status: days[i].status,
                checkInTime: days[i].checkInTime,
              ),
              if (i != days.length - 1)
                Divider(height: 1, color: const Color(0xFFF1F5F9)),
            ],
          ],
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String dayKey;
  final String status;
  final int? checkInTime;

  const _DetailRow({
    required this.dayKey,
    required this.status,
    this.checkInTime,
  });

  String get _time {
    if (checkInTime == null) return '—';
    final t = DateTime.fromMillisecondsSinceEpoch(checkInTime!);
    return ShiftModel.formatMinutes(t.hour * 60 + t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final color = AttendanceStatus.color(status);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(dayKey.tr,
                style: context.typography.smMedium
                    .copyWith(color: const Color(0xFF1E293B))),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(AttendanceStatus.icon(status), size: 15.sp, color: color),
                SizedBox(width: 5.w),
                Text(AttendanceStatus.labelKey(status).tr,
                    style: context.typography.xsMedium.copyWith(color: color)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(_time,
                textAlign: TextAlign.end,
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }
}
