import '../../../../../index/index_main.dart';

/// Confirmation sheet for permanently deleting a child (the "registered by
/// mistake" action). Unlike withdrawal it leaves no departure record, so the
/// copy makes the irreversible, no-trace nature explicit before confirming.
class DeleteChildSheet extends StatelessWidget {
  const DeleteChildSheet({super.key, required this.controller});

  final ChildProfileController controller;

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
                    'child_delete_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'child_delete_subtitle'.tr,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            SizedBox(height: 22.h),
            PrimaryTextButton(
              label: AppText(
                text: 'child_delete_button'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.activityRed,
              onTap: () {
                Get.back();
                controller.deleteChild();
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

/// Opens the permanent-delete confirmation sheet.
Future<void> showDeleteChildSheet(ChildProfileController controller) {
  return Get.bottomSheet(
    DeleteChildSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
