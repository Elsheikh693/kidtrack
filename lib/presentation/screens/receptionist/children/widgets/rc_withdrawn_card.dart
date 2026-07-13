import '../../../../../index/index_main.dart';
import '../receptionist_children_controller.dart';

/// Tappable "withdrawn this month" stat on the reception Children tab. Opens the
/// read-only list of children who left the nursery this month, with reasons.
class RcWithdrawnCard extends StatelessWidget {
  final ReceptionistChildrenController controller;
  const RcWithdrawnCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.leftThisMonth.value;
      return Padding(
        padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 8.h),
        child: GestureDetector(
          onTap: count == 0 ? null : controller.openWithdrawnList,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.activityRed.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.activityRed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(Icons.logout_rounded,
                      color: AppColors.activityRed, size: 16),
                ),
                SizedBox(width: 10.w),
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
