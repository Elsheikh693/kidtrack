import '../../../../../index/index_main.dart';
import '../controller.dart';

class PaymentReminderSection extends StatelessWidget {
  const PaymentReminderSection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final invoices = controller.pendingInvoices;
      if (invoices.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 18.sp,
                      color: Color(0xFFDC2626)),
                    SizedBox(width: 6.w),
                    Text(
                      'payment_reminder_title'.tr,
                      style: context.typography.mdBold.copyWith(color: Color(0xFF1E293B), fontSize: 16),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${invoices.length}',
                          style: context.typography.displaySmBold.copyWith(color: Colors.white, fontSize: 11),
                        ),
                      )),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(parentInvoicesView),
                  child: Text(
                    'payment_reminder_view_all'.tr,
                    style: context.typography.smSemiBold.copyWith(color: Color(0xFFD97706), fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...invoices.map((i) => _ReminderCard(invoice: i)),
          ],
        ),
      );
    });
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.invoice});
  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final isOverdue = invoice.status == 'overdue';
    final color = isOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final bgColor = isOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);

    return GestureDetector(
      onTap: () => Get.toNamed(parentInvoicesView),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8.r,
              offset: Offset(0.w, 2.h)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isOverdue
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_outlined,
                color: color,
                size: 22.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.categoryName ??
                        invoice.title ??
                        'parent_invoices_invoice'.tr,
                    style: context.typography.displaySmBold.copyWith(color: Color(0xFF1E293B), fontSize: 14),
                  ),
                  SizedBox(height: 4.h),
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'invoice_status_${invoice.status}'.tr,
                        style: context.typography.smSemiBold.copyWith(color: color, fontSize: 11),
                      )),
                    if (invoice.dueDate != null &&
                        invoice.key?.startsWith('fee_') != true) ...[
                      SizedBox(width: 8.w),
                      Text(
                        _fmtDate(invoice.dueDate!),
                        style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${invoice.totalAmount.toStringAsFixed(0)} ${'currency'.tr}',
                  style: context.typography.mdBold.copyWith(color: color, fontSize: 16),
                ),
                SizedBox(height: 6.h),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 13.sp,
                  color: color.withValues(alpha: 0.5)),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }
}
