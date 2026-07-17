import '../../../../../../index/index_main.dart';

/// Monthly payments summary: total collected for the child this month + how
/// many payments were recorded.
class MonthlyFinancialCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyFinancialCard({super.key, required this.controller});

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final paid = controller.monthPaid.value;
      final count = controller.monthTxCount;
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
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child:
                  Icon(Icons.receipt_long_rounded, color: _green, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_financial_title'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(color: const Color(0xFF1E293B))),
                  SizedBox(height: 2.h),
                  Text(
                    count == 0
                        ? 'report_monthly_no_payments'.tr
                        : 'report_monthly_payments_count'
                            .trParams({'n': '$count'}),
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(paid.toStringAsFixed(0),
                    style: context.typography.lgBold.copyWith(color: _green)),
                Text('currency'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      );
    });
  }
}
