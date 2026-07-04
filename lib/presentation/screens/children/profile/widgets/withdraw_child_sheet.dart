import '../../../../../index/index_main.dart';

/// Bottom sheet for marking a child as permanently withdrawn from the nursery.
/// The manager needs a reason on record, so a preset must be picked before the
/// confirm button unlocks; an optional free-text note is appended after it.
class WithdrawChildSheet extends StatefulWidget {
  const WithdrawChildSheet({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  State<WithdrawChildSheet> createState() => _WithdrawChildSheetState();
}

class _WithdrawChildSheetState extends State<WithdrawChildSheet> {
  // Preset reason keys — label resolved through .tr at build time.
  static const _reasonKeys = [
    'child_withdraw_reason_transfer',
    'child_withdraw_reason_relocation',
    'child_withdraw_reason_financial',
    'child_withdraw_reason_dissatisfied',
    'child_withdraw_reason_other',
  ];

  String? _selectedKey;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selectedKey == null) return;
    final label = _selectedKey!.tr;
    final note = _noteController.text.trim();
    final reason = note.isEmpty ? label : '$label — $note';
    Get.back();
    widget.controller.withdraw(reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
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
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.activityRed,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'child_withdraw_title'.tr,
                      style: context.typography.lgBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'child_withdraw_subtitle'.tr,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
              SizedBox(height: 18.h),
              Text(
                'child_withdraw_reason_label'.tr,
                style: context.typography.mdMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 10.h),
              ..._reasonKeys.map(_reasonTile),
              SizedBox(height: 14.h),
              Text(
                'child_withdraw_note_label'.tr,
                style: context.typography.mdMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 10.h),
              AppTextField(
                controller: _noteController,
                hintText: 'child_withdraw_note_hint'.tr,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: 22.h),
              PrimaryTextButton(
                label: AppText(
                  text: 'child_withdraw_confirm'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
                appButtonSize: AppButtonSize.large,
                onTap: _selectedKey == null ? null : _confirm,
                customBackgroundColor: AppColors.activityRed,
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
      ),
    );
  }

  Widget _reasonTile(String key) {
    final selected = _selectedKey == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedKey = key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.activityRed.withValues(alpha: 0.06)
              : AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.activityRed : AppColors.grayLight,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.activityRed
                  : AppColors.textSecondaryParagraph,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                key.tr,
                style: context.typography.smMedium.copyWith(
                  color: selected
                      ? AppColors.textDefault
                      : AppColors.textSecondaryParagraph,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the withdrawal sheet for [controller]'s current child.
Future<void> showWithdrawChildSheet(ChildProfileController controller) {
  return Get.bottomSheet(
    WithdrawChildSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
