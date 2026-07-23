import '../../../../../index/index_main.dart';

/// Confirmation sheet for permanently removing a guardian from the child. If the
/// guardian has no other children they are fully erased — records AND their
/// Firebase Auth login — so the copy makes the irreversible nature explicit.
class GuardianRemoveSheet extends StatelessWidget {
  const GuardianRemoveSheet({
    super.key,
    required this.controller,
    required this.parent,
  });

  final ChildProfileController controller;
  final ParentModel parent;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
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
                  child: Icon(Icons.person_remove_rounded,
                      color: AppColors.activityRed, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'guardian_remove_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'guardian_remove_subtitle'.trParams({'name': parent.name}),
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            SizedBox(height: 22.h),
            PrimaryTextButton(
              label: AppText(
                text: 'guardian_remove_button'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.activityRed,
              onTap: () {
                Get.back();
                controller.removeGuardian(parent);
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

/// Opens the guardian removal confirmation sheet.
Future<void> showGuardianRemoveSheet(
  ChildProfileController controller,
  ParentModel parent,
) {
  return Get.bottomSheet(
    GuardianRemoveSheet(controller: controller, parent: parent),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
