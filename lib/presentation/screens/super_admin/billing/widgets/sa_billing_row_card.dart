import '../../../../../index/index_main.dart';
import '../../../billing/widgets/billing_status_pill.dart';

/// One nursery row in the SuperAdmin billing list.
class SaBillingRowCard extends StatelessWidget {
  const SaBillingRowCard({super.key, required this.row, required this.onTap});

  final SaBillingRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.account_balance_rounded,
                      color: const Color(0xFF4F46E5), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.nursery.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.child_care_rounded,
                              color: const Color(0xFF94A3B8), size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'billing_children_count'
                                .trParams({'n': row.childCount.toString()}),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${row.amount.toStringAsFixed(0)} ${'currency'.tr}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    BillingStatusPill(paid: row.paid, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
