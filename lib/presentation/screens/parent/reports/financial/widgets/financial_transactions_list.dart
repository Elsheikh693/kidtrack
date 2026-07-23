import '../../../../../../index/index_main.dart';

/// The chronological list of collections recorded for the child.
class FinancialTransactionsList extends StatelessWidget {
  final FinancialReportController controller;
  const FinancialTransactionsList({super.key, required this.controller});

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
        final items = controller.items;
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _Row(tx: items[i]),
              if (i != items.length - 1)
                Divider(height: 1, color: const Color(0xFFF1F5F9)),
            ],
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  final FinancialTransactionModel tx;
  const _Row({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.receipt_long_rounded,
                color: const Color(0xFF16A34A), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName.trim().isEmpty
                      ? 'report_financial_other'.tr
                      : tx.categoryName.trim(),
                  style: context.typography.smMedium
                      .copyWith(color: const Color(0xFF1E293B)),
                ),
                SizedBox(height: 2.h),
                Text(FinancialReportController.formatDate(tx.date),
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Text('${tx.amount.toStringAsFixed(0)} ${'currency'.tr}',
              style: context.typography.smSemiBold
                  .copyWith(color: const Color(0xFF16A34A))),
        ],
      ),
    );
  }
}
