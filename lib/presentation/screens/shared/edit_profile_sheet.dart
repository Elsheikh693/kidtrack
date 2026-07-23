import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class EditProfileSheet extends StatefulWidget {
  final bool isStaff;
  const EditProfileSheet({super.key, this.isStaff = false});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  bool _loading = false;
  final _session = SessionService();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _session.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('edit_profile_name_required'.tr);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    Loader.show();
    try {
      final uid = _session.userId ?? '';
      final ts = DateTime.now().millisecondsSinceEpoch;

      await FirebaseDatabase.instance.ref('users/$uid').update({
        'name': name,
        'updatedAt': ts,
      });

      if (widget.isStaff) {
        final nurseryId = _session.nurseryId ?? '';
        await FirebaseDatabase.instance
            .ref('platform/$nurseryId/staff/$uid')
            .update({'name': name, 'updatedAt': ts});
      }

      final updated = _session.currentUser!.copyWith(name: name);
      await _session.updateUser(updated);

      Loader.dismiss();
      Loader.showSuccess('edit_profile_success'.tr);
      Get.back();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('edit_profile_error'.tr);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      const _DeleteAccountConfirmDialog(),
      barrierDismissible: true,
    );
    if (confirmed != true) return;

    Loader.show();
    try {
      final uid = _session.userId ?? '';
      final user = FirebaseAuth.instance.currentUser;

      if (uid.isNotEmpty) {
        await FirebaseDatabase.instance.ref('users/$uid').remove();
      }

      try {
        await user?.delete();
      } on FirebaseAuthException catch (e) {
        // If the session is too old Firebase blocks the delete; the account
        // data is already removed, so we still proceed to sign the user out.
        if (e.code != 'requires-recent-login') rethrow;
      }

      Loader.dismiss();
      await performLogout();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('delete_account_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                Center(
                  child: Container(
                    width: 76.w,
                    height: 76.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 38.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    'edit_profile_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'edit_profile_name_label'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  style: context.typography.smMedium
                      .copyWith(color: AppColors.textDefault),
                  decoration: InputDecoration(
                    hintText: 'edit_profile_name_hint'.tr,
                    filled: true,
                    fillColor: AppColors.backgroundNeutral100,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.grayMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                  ),
                ),
                SizedBox(height: 26.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'edit_profile_save'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _deleteAccount,
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 32.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'delete_account_link'.tr,
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.grayMedium,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountConfirmDialog extends StatelessWidget {
  const _DeleteAccountConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.errorForeground,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'delete_account_confirm_title'.tr,
                style: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 8.h),
              Text(
                'delete_account_confirm_message'.tr,
                textAlign: TextAlign.center,
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: BorderSide(
                          color: AppColors.borderNeutralPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'common_cancel'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorForeground,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'delete_account_confirm_button'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showEditProfileSheet({bool isStaff = false}) {
  Get.bottomSheet(
    EditProfileSheet(isStaff: isStaff),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
