import '../../../../../../index/index_main.dart';

/// Week-over-week movement: last week's rate vs this week's, with the delta as
/// an up/down chip. Hidden when there is no prior week to compare against.
class AttendanceTrendCard extends StatelessWidget {
  final WeeklyAttendanceController controller;
  const AttendanceTrendCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasTrend.value) return const SizedBox.shrink();
      final delta = controller.trendDelta.value;
      final up = delta >= 0;
      final color =
          delta == 0 ? const Color(0xFF64748B) : (up ? const Color(0xFF16A34A) : const Color(0xFFDC2626));
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
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
        child: Row(
          children: [
            _Side(
              labelKey: 'report_trend_last',
              value: controller.trendLastWeek.value,
              muted: true,
            ),
            Container(
              width: 1,
              height: 28.h,
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              color: const Color(0xFFE2E8F0),
            ),
            _Side(
              labelKey: 'report_trend_this',
              value: controller.trendThisWeek.value,
              muted: false,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(
                    delta == 0
                        ? Icons.remove_rounded
                        : (up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                    size: 14.sp,
                    color: color,
                  ),
                  SizedBox(width: 2.w),
                  Text('${delta.abs()}%',
                      style: context.typography.xsBold.copyWith(color: color)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Side extends StatelessWidget {
  final String labelKey;
  final int value;
  final bool muted;
  const _Side(
      {required this.labelKey, required this.value, required this.muted});

  @override
  Widget build(BuildContext context) {
    final color =
        muted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelKey.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
          SizedBox(height: 2.h),
          Text('$value%',
              style: context.typography.mdBold.copyWith(color: color)),
        ],
      ),
    );
  }
}
