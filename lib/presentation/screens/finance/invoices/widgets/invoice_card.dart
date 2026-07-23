import '../../../../../index/index_main.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel item;
  final String childName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMarkPaid;

  const InvoiceCard({
    super.key,
    required this.item,
    required this.childName,
    required this.onEdit,
    required this.onDelete,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    final isPaid = item.status == 'paid';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8.r, offset: Offset(0, 2.h))
        ],
        border: item.status == 'overdue'
            ? Border.all(color: const Color(0xFFDC2626).withOpacity(0.3))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(children: [
              // Category color dot
              if (item.categoryId != null)
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childName,
                      style: context.typography.displaySmBold.copyWith(color: Color(0xFF1E293B)),
                    ),
                    if (item.categoryName != null || item.title != null)
                      Text(
                        [item.categoryName, item.title].whereType<String>().join(' • '),
                        style: context.typography.xsRegular.copyWith(color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'invoice_status_${item.status}'.tr,
                  style: context.typography.xsMedium.copyWith(color: statusColor),
                ),
              ),
              _InvoiceMenu(onEdit: onEdit, onDelete: onDelete),
            ]),
            SizedBox(height: 10.h),

            // ── Amounts ─────────────────────────────────────────────────────
            Row(children: [
              _AmountChip(label: 'invoice_amount'.tr, value: item.amount.toStringAsFixed(2)),
              SizedBox(width: 8.w),
              if (item.discount > 0) ...[
                _AmountChip(
                  label: 'invoice_discount'.tr,
                  value: item.discount.toStringAsFixed(2),
                  color: const Color(0xFF16A34A),
                ),
                SizedBox(width: 8.w),
              ],
              _AmountChip(
                label: 'invoice_total'.tr,
                value: item.totalAmount.toStringAsFixed(2),
                color: AppColors.primary,
              ),
            ]),

            // ── Due date / paid date ─────────────────────────────────────────
            if (item.dueDate != null || item.paidAt != null) ...[
              SizedBox(height: 8.h),
              Row(children: [
                if (item.dueDate != null) ...[
                  Icon(Icons.calendar_today_outlined, size: 13.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(item.dueDate!),
                    style: context.typography.xsRegular.copyWith(
                      color: item.status == 'overdue' ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
                if (isPaid && item.paidAt != null) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.check_circle_outline, size: 13.sp, color: const Color(0xFF16A34A)),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(item.paidAt!),
                    style: context.typography.xsRegular.copyWith(color: Color(0xFF16A34A)),
                  ),
                  if (item.paymentMethod != null) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '• ${'payment_method_${item.paymentMethod}'.tr}',
                      style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ],
              ]),
            ],

            // ── Transfer screenshot (guardian-submitted proof) ───────────────
            if (item.proofUrl != null && item.proofUrl!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              _ProofBanner(url: item.proofUrl!),
            ],

            // ── Mark as paid button ──────────────────────────────────────────
            if (!isPaid && onMarkPaid != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onMarkPaid,
                  icon: Icon(Icons.payments_outlined, size: 16.sp),
                  label: Text('invoice_mark_paid'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return const Color(0xFF16A34A);
      case 'overdue':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

/// Green banner shown when a guardian has uploaded a transfer screenshot for
/// this invoice. Tapping opens the full image so reception/CS (and the manager)
/// can verify it before recording the collection.
class _ProofBanner extends StatelessWidget {
  final String url;
  const _ProofBanner({required this.url});

  void _view() => showFullImage(url);

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    return GestureDetector(
      onTap: _view,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long_rounded, size: 16.sp, color: green),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'invoice_proof_badge'.tr,
                style: context.typography.xsMedium.copyWith(color: green),
              ),
            ),
            Text(
              'invoice_proof_view'.tr,
              style: context.typography.xsMedium.copyWith(color: green),
            ),
            Icon(Icons.chevron_left_rounded, size: 16.sp, color: green),
          ],
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountChip(
      {required this.label, required this.value, this.color = const Color(0xFF475569)});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typography.xsRegular.copyWith(color: Color(0xFF94A3B8))),
          Text(value,
              style: context.typography.xsMedium.copyWith(color: color)),
        ],
      );
}

class _InvoiceMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _InvoiceMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Act>(
        icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
        onSelected: (a) {
          if (a == _Act.edit) onEdit();
          if (a == _Act.delete) onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _Act.edit,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18.sp, color: const Color(0xFF475569)),
              SizedBox(width: 10.w),
              Text('invoice_edit'.tr),
            ]),
          ),
          PopupMenuItem(
            value: _Act.delete,
            child: Row(children: [
              Icon(Icons.delete_outline, size: 18.sp, color: const Color(0xFFDC2626)),
              SizedBox(width: 10.w),
              Text('invoice_delete'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFDC2626))),
            ]),
          ),
        ],
      );
}

enum _Act { edit, delete }
