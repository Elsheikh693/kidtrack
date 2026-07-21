import '../../../../../index/index_main.dart';

/// "withdrawn this month" stat on the owner's executive dashboard. Always shown
/// (even at zero, like the manager/reception cards); tappable only when someone
/// left, opening the read-only list of children who left this month (for the
/// current scope) with the reason each one left.
class OwnerWithdrawnCard extends StatelessWidget {
  const OwnerWithdrawnCard({super.key, required this.controller});

  final OwnerExecutiveController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.withdrawnThisMonth.length;
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: GestureDetector(
          onTap: count == 0 ? null : controller.openWithdrawnList,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.activityRed.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.activityRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.logout_rounded,
                      color: AppColors.activityRed, size: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'withdrawn_this_month_label'.tr,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                Text(
                  '$count',
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.activityRed),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.activityRed, size: 20),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
