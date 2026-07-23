import '../../../../../index/index_main.dart';

/// One daily-expense charge row: the child, the reason, the amount, a payment
/// status chip and — while still unpaid — an edit/delete menu.
class ChildChargeCard extends StatelessWidget {
  const ChildChargeCard({
    super.key,
    required this.controller,
    required this.charge,
  });

  final ChildChargesController controller;
  final InvoiceModel charge;

  @override
  Widget build(BuildContext context) {
    final canModify = controller.canModify(charge);
    final amount = charge.totalAmount.toStringAsFixed(
      charge.totalAmount % 1 == 0 ? 0 : 2,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChildAvatar(
                name: controller.childName(charge.childId),
                imageUrl: controller.childImage(charge.childId),
                size: 46,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      charge.title?.isNotEmpty == true
                          ? charge.title!
                          : 'daily_expense_reason'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.childName(charge.childId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.grayMedium),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          '$amount ${'currency'.tr}',
                          style: context.typography.smSemiBold
                              .copyWith(color: AppColors.primary),
                        ),
                        SizedBox(width: 8.w),
                        _StatusChip(charge: charge),
                      ],
                    ),
                  ],
                ),
              ),
              if (canModify)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: AppColors.grayMedium, size: 20.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') controller.openEdit(charge);
                    if (v == 'delete') _confirmDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('edit'.tr,
                          style: context.typography.smRegular),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('delete'.tr,
                          style: context.typography.smRegular
                              .copyWith(color: AppColors.errorForeground)),
                    ),
                  ],
                ),
            ],
          ),
          if (!charge.isFullyPaid) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.openCollect(charge),
                icon: Icon(Icons.check_circle_outline_rounded,
                    size: 18.sp, color: AppColors.primary),
                label: Text(
                  'daily_expense_collect'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'daily_expense_delete_title'.tr,
      middleText: 'daily_expense_delete_confirm'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.errorForeground,
      onConfirm: () {
        Get.back();
        controller.delete(charge);
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.charge});
  final InvoiceModel charge;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    if (charge.isFullyPaid) {
      color = const Color(0xFF16A34A);
      label = 'daily_expense_status_paid'.tr;
    } else if (charge.isPartiallyPaid) {
      color = const Color(0xFFD97706);
      label = 'daily_expense_status_partial'.tr;
    } else {
      color = const Color(0xFFDC2626);
      label = 'daily_expense_status_pending'.tr;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}
