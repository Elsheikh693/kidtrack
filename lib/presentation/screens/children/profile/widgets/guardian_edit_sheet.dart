import '../../../../../index/index_main.dart';
import 'guardian_remove_sheet.dart';

/// Bottom sheet for correcting a guardian's details (name / phone / email) on
/// the child profile. Editing writes only the guardian's own record — the
/// parent↔child link is untouched. Leadership additionally gets a "remove
/// guardian" action here (reception can fix a name but not delete an account).
class GuardianEditSheet extends StatefulWidget {
  const GuardianEditSheet({
    super.key,
    required this.controller,
    required this.parent,
  });

  final ChildProfileController controller;
  final ParentModel parent;

  @override
  State<GuardianEditSheet> createState() => _GuardianEditSheetState();
}

class _GuardianEditSheetState extends State<GuardianEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parent.name);
    _phoneController = TextEditingController(text: widget.parent.phone ?? '');
    _emailController = TextEditingController(text: widget.parent.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Loader.showError('guardian_edit_name_required'.tr);
      return;
    }
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    widget.controller.updateGuardian(
      widget.parent.copyWith(
        name: name,
        phone: phone.isEmpty ? null : phone,
        email: email.isEmpty ? null : email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                Text(
                  'guardian_edit_title'.tr,
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 18.h),
                _Label(text: 'guardian_edit_name_label'.tr),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _nameController,
                  hintText: 'guardian_edit_name_hint'.tr,
                ),
                SizedBox(height: 14.h),
                _Label(text: 'guardian_edit_phone_label'.tr),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _phoneController,
                  hintText: 'guardian_edit_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 14.h),
                _Label(text: 'guardian_edit_email_label'.tr),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _emailController,
                  hintText: 'guardian_edit_email_hint'.tr,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 22.h),
                PrimaryTextButton(
                  label: AppText(
                    text: 'common_save'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                  appButtonSize: AppButtonSize.large,
                  onTap: _save,
                ),
                if (widget.controller.canDelete) ...[
                  SizedBox(height: 10.h),
                  SecondaryTextButton(
                    label: AppText(
                      text: 'guardian_remove_action'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.activityRed),
                    ),
                    appButtonSize: AppButtonSize.large,
                    onTap: () {
                      Get.back();
                      showGuardianRemoveSheet(widget.controller, widget.parent);
                    },
                  ),
                ],
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
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.mdMedium.copyWith(color: AppColors.textDefault),
    );
  }
}

/// Opens the guardian edit sheet for [parent] on [controller]'s child.
Future<void> showGuardianEditSheet(
  ChildProfileController controller,
  ParentModel parent,
) {
  return Get.bottomSheet(
    GuardianEditSheet(controller: controller, parent: parent),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
