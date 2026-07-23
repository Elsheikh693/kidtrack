import '../../../../../../index/index_main.dart';

/// Hero card: total collected for the child, plus this-month total and the
/// number of recorded payments.
class FinancialSummaryCard extends StatelessWidget {
  final FinancialReportController controller;
  const FinancialSummaryCard({super.key, required this.controller});

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
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
            Text('report_financial_total_paid'.tr,
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF94A3B8))),
            SizedBox(height: 6.h),
            Text(
              '${controller.totalPaid.value.toStringAsFixed(0)} ${'currency'.tr}',
              style: context.typography.xlBold.copyWith(color: _green),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _Mini(
                  labelKey: 'report_financial_this_month',
                  value:
                      '${controller.thisMonthTotal.value.toStringAsFixed(0)} ${'currency'.tr}',
                  color: AppColors.primary,
                ),
                Container(
                    width: 1, height: 34.h, color: const Color(0xFFE2E8F0)),
                _Mini(
                  labelKey: 'report_financial_payments',
                  value: '${controller.paymentsCount.value}',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String labelKey;
  final String value;
  final Color color;
  const _Mini(
      {required this.labelKey, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: context.typography.mdBold.copyWith(color: color)),
          SizedBox(height: 2.h),
          Text(labelKey.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
