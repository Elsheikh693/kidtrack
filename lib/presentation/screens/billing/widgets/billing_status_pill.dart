import '../../../../index/index_main.dart';

/// Small paid / unpaid badge used across the billing screens.
class BillingStatusPill extends StatelessWidget {
  const BillingStatusPill({super.key, required this.paid, this.compact = false});

  final bool paid;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = paid ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8.w : 12.w, vertical: compact ? 4.h : 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paid ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: color,
            size: compact ? 13.sp : 15.sp,
          ),
          SizedBox(width: 5.w),
          Text(
            (paid ? 'billing_status_paid' : 'billing_status_unpaid').tr,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11.sp : 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
