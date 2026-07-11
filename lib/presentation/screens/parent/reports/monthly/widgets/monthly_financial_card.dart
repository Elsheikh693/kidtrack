import '../../../../../../index/index_main.dart';

/// Monthly payments summary: total collected for the child this month.
class MonthlyFinancialCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyFinancialCard({super.key, required this.controller});

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
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
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.receipt_long_rounded, color: _green, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text('report_financial_title'.tr,
                  style: context.typography.smMedium
                      .copyWith(color: const Color(0xFF1E293B))),
            ),
            Text(
              '${controller.monthPaid.value.toStringAsFixed(0)} ${'currency'.tr}',
              style: context.typography.mdBold.copyWith(color: _green),
            ),
          ],
        ),
      ),
    );
  }
}
