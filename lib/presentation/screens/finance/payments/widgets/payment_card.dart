import '../../../../../index/index_main.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel item;
  final String childName;
  final String? categoryName;
  final VoidCallback onDelete;

  const PaymentCard({
    super.key,
    required this.item,
    required this.childName,
    this.categoryName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final d = DateTime.fromMillisecondsSinceEpoch(item.paidAt);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: const Color(0xFF16A34A),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (categoryName != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    categoryName!,
                    style: context.typography.xsRegular.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Row(children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'payment_method_${item.method}'.tr,
                      style: context.typography.xsRegular
                          .copyWith(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${d.day}/${d.month}/${d.year}',
                    style: context.typography.xsRegular
                        .copyWith(fontSize: 11, color: const Color(0xFF94A3B8)),
                  ),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.amount.toStringAsFixed(0)} ${'currency'.tr}',
                style: context.typography.mdBold.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF16A34A),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18.sp, color: const Color(0xFF94A3B8)),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
