import '../../../../../index/index_main.dart';

/// One nursery payment account row in the manager editor: type icon, name +
/// number/link, and an edit/delete menu.
class PaymentAccountTile extends StatelessWidget {
  final PaymentAccountModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentAccountTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        item.isInstapay ? const Color(0xFF6D4AFF) : const Color(0xFF16A34A);
    final subtitle = item.number.isNotEmpty ? item.number : item.link;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              item.isInstapay
                  ? Icons.qr_code_rounded
                  : Icons.account_balance_wallet_rounded,
              size: 22.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        item.isInstapay
                            ? 'nursery_pay_type_instapay'.tr
                            : 'nursery_pay_type_wallet'.tr,
                        style:
                            context.typography.xsMedium.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondaryParagraph),
            onSelected: (v) => v == 0 ? onEdit() : onDelete(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 0,
                child: Row(children: [
                  Icon(Icons.edit_outlined,
                      size: 18.sp, color: const Color(0xFF475569)),
                  SizedBox(width: 10.w),
                  Text('nursery_pay_account_edit'.tr),
                ]),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18.sp, color: AppColors.errorForeground),
                  SizedBox(width: 10.w),
                  Text('nursery_pay_account_delete'.tr,
                      style: context.typography.smRegular
                          .copyWith(color: AppColors.errorForeground)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
