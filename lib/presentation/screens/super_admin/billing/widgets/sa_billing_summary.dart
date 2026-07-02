import '../../../../../index/index_main.dart';

/// Collected / outstanding totals strip on the SuperAdmin billing list.
class SaBillingSummary extends StatelessWidget {
  const SaBillingSummary({
    super.key,
    required this.collected,
    required this.outstanding,
    required this.paidCount,
    required this.total,
  });

  final double collected;
  final double outstanding;
  final int paidCount;
  final int total;

  String _money(double v) => '${v.toStringAsFixed(0)} ${'currency'.tr}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Cell(
                  label: 'billing_summary_collected'.tr,
                  value: _money(collected),
                  color: const Color(0xFF16A34A),
                  icon: Icons.check_circle_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _Cell(
                  label: 'billing_summary_outstanding'.tr,
                  value: _money(outstanding),
                  color: const Color(0xFFDC2626),
                  icon: Icons.pending_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_rounded,
                  color: const Color(0xFF64748B), size: 15.sp),
              SizedBox(width: 8.w),
              Text(
                'billing_summary_progress'.trParams({
                  'paid': paidCount.toString(),
                  'total': total.toString(),
                }),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
