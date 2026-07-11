import '../../../../../../index/index_main.dart';
import 'attendance_status.dart';

/// A soft, auto-generated sentence about the week's attendance — encouraging in
/// tone, never a reprimand. Tinted by the current rate.
class AttendanceInsightCard extends StatelessWidget {
  final WeeklyAttendanceController controller;
  const AttendanceInsightCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final text = controller.insight.value;
      if (text.isEmpty) return const SizedBox.shrink();
      final color = AttendanceStatus.rateColor(controller.rate.value);
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.lightbulb_outline_rounded,
                  color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_insight_title'.tr,
                      style: context.typography.xsMedium.copyWith(color: color)),
                  SizedBox(height: 4.h),
                  Text(text,
                      style: context.typography.smRegular.copyWith(
                          height: 1.5, color: const Color(0xFF334155))),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
