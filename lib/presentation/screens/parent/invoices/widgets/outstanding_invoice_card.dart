import '../../../../../index/index_main.dart';

/// A single unpaid/partial invoice on the guardian finance screen, with a
/// "pay now" button that opens the transfer + upload-screenshot sheet. When a
/// screenshot is already submitted it shows an "awaiting review" state instead.
class OutstandingInvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onPay;

  const OutstandingInvoiceCard({
    super.key,
    required this.invoice,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final pending = invoice.hasPendingProof;
    final title = [invoice.categoryName, invoice.title]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' • ');
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'parent_payments_uncategorized'.tr : title,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B)),
                ),
              ),
              Text(
                '${invoice.remaining.toStringAsFixed(0)} ${'currency'.tr}',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (invoice.dueDate != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(invoice.dueDate!),
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          if (pending)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 15.sp, color: const Color(0xFFD97706)),
                  SizedBox(width: 6.w),
                  Text(
                    'pay_invoice_proof_pending'.tr,
                    style: context.typography.xsMedium
                        .copyWith(color: const Color(0xFFD97706)),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: onPay,
                    child: Text(
                      'pay_invoice_change_proof'.tr,
                      style: context.typography.xsMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: Icon(Icons.upload_file_rounded, size: 16.sp),
                label: Text('parent_pay_now'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }
}
