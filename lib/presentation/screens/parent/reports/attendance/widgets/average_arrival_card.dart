import '../../../../../../index/index_main.dart';

/// Average check-in time for the week, with an on-time / minutes-late verdict
/// against the child's shift start (shown only when a shift is configured).
class AverageArrivalCard extends StatelessWidget {
  final WeeklyAttendanceController controller;
  const AverageArrivalCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final comparison = controller.arrivalComparison.value;
      final onTime = controller.arrivalOnTime.value;
      final accent = comparison.isEmpty
          ? AppColors.primary
          : (onTime ? const Color(0xFF16A34A) : const Color(0xFFD97706));
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
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.login_rounded, color: accent, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_avg_arrival'.tr,
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF94A3B8))),
                  SizedBox(height: 2.h),
                  Text(controller.avgArrivalLabel.value,
                      style: context.typography.mdBold
                          .copyWith(color: const Color(0xFF1E293B))),
                ],
              ),
            ),
            if (comparison.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      onTime
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded,
                      size: 14.sp,
                      color: accent,
                    ),
                    SizedBox(width: 4.w),
                    Text(comparison,
                        style: context.typography.xsMedium
                            .copyWith(color: accent)),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
