import '../../../../index/index_main.dart';

/// Per-branch breakdown of a nursery's monthly platform bill: one row per
/// branch (children × price) then the grand total. Shared by owner/manager and
/// the SuperAdmin detail screen.
class BranchBreakdownCard extends StatelessWidget {
  const BranchBreakdownCard({super.key, required this.bill});

  final PlatformBillModel bill;

  String _money(double v) => '${v.toStringAsFixed(0)} ${'currency'.tr}';

  @override
  Widget build(BuildContext context) {
    final branches = bill.branches;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_rounded,
                  color: const Color(0xFF4F46E5), size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'billing_breakdown_title'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (branches.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'billing_no_children'.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            )
          else
            ...branches.map((b) => _BranchLine(
                  name: b.branchName,
                  count: b.childCount,
                  amount: _money(b.amount),
                )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Row(
            children: [
              Text(
                'billing_total'.tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                'billing_children_count'.trParams({
                  'n': bill.totalChildCount.toString(),
                }),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                _money(bill.totalAmount),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BranchLine extends StatelessWidget {
  const _BranchLine({
    required this.name,
    required this.count,
    required this.amount,
  });

  final String name;
  final int count;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.store_mall_directory_rounded,
                color: const Color(0xFF6366F1), size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'billing_children_count'.trParams({'n': count.toString()}),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
