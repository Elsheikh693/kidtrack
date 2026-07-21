import '../../../../../index/index_main.dart';

/// Confirmation sheet for permanently deleting a staff member. Deletion is
/// irreversible — it removes the staff record, permissions, and login code — so
/// the copy names the person and makes the no-undo nature explicit.
class StaffDeleteSheet extends StatelessWidget {
  const StaffDeleteSheet({
    super.key,
    required this.controller,
    required this.staff,
  });

  final StaffListController controller;
  final StaffModel staff;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 18.h),
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.activityRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(Icons.delete_forever_rounded,
                      color: AppColors.activityRed, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'staff_delete_permanent_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'staff_delete_subtitle'.trParams({'name': staff.name}),
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            SizedBox(height: 22.h),
            PrimaryTextButton(
              label: AppText(
                text: 'staff_delete_button'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.activityRed,
              onTap: () {
                Get.back();
                controller.deleteStaff(staff);
              },
            ),
            SizedBox(height: 10.h),
            SecondaryTextButton(
              label: AppText(
                text: 'common_cancel'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
              appButtonSize: AppButtonSize.large,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the permanent-delete confirmation sheet for [staff].
Future<void> showStaffDeleteSheet(
  StaffListController controller,
  StaffModel staff,
) {
  return Get.bottomSheet(
    StaffDeleteSheet(controller: controller, staff: staff),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
