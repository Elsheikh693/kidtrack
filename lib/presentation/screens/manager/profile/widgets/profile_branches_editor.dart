import 'package:geolocator/geolocator.dart';
import '../../../../../index/index_main.dart';

/// Manager-side editor for the nursery's canonical branches
/// (platform/{nurseryId}/branches). Shows the branches created during owner
/// setup, lets the manager enrich each one's contact/location details, add a
/// new branch together with its manager account, or delete a branch.
class ProfileBranchesEditor extends StatelessWidget {
  const ProfileBranchesEditor({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  void _openDetails(BranchModel branch) {
    Get.bottomSheet(
      _BranchDetailsSheet(
        initial: branch,
        onSave: (updated) => controller.updateBranchDetails(updated),
      ),
      isScrollControlled: true,
    );
  }

  void _openAdd() {
    Get.bottomSheet(
      _AddBranchSheet(
        onSubmit: (name, managerName, phone) =>
            controller.addBranchWithManager(
          branchName: name,
          managerName: managerName,
          phone: phone,
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, BranchModel branch) {
    Get.defaultDialog(
      title: 'manager_branch_delete_title'.tr,
      middleText: 'manager_branch_delete_confirm'.tr,
      textConfirm: 'common_delete'.tr,
      textCancel: 'common_cancel'.tr,
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.errorForeground,
      onConfirm: () {
        Get.back();
        controller.deleteBranch(branch.key ?? '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.branchesLoading.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          for (final branch in controller.branches) ...[
            _BranchTile(
              branch: branch,
              managerName: controller.managerForBranch(branch.key)?.name,
              onEdit: () => _openDetails(branch),
              onDelete: () => _confirmDelete(context, branch),
            ),
            SizedBox(height: 10.h),
          ],
          GestureDetector(
            onTap: _openAdd,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.primary40, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 20.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  AppText(
                    text: 'manager_branch_add'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  final BranchModel branch;
  final String? managerName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchTile({
    required this.branch,
    required this.managerName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        children: [
          Icon(Icons.store_mall_directory_rounded,
              size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        text: branch.name,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                        maxLines: 1,
                      ),
                    ),
                    if (branch.isMain) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: AppText(
                          text: 'manager_branch_main_badge'.tr,
                          textStyle: context.typography.xsRegular
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                if ((managerName ?? '').isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  AppText(
                    text:
                        '${'manager_branch_manager_label'.tr}: ${managerName!}',
                    textStyle: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                    maxLines: 1,
                  ),
                ],
                if ((branch.address ?? '').isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  AppText(
                    text: branch.address!,
                    textStyle: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph),
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.edit_rounded,
                  size: 18.sp, color: AppColors.primary60),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.delete_outline_rounded,
                  size: 18.sp, color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit sheet for an existing branch's contact + location details. Identity
/// fields (key, isMain, nursery, manager) are preserved via copyWith.
class _BranchDetailsSheet extends StatefulWidget {
  final BranchModel initial;
  final void Function(BranchModel) onSave;

  const _BranchDetailsSheet({required this.initial, required this.onSave});

  @override
  State<_BranchDetailsSheet> createState() => _BranchDetailsSheetState();
}

class _BranchDetailsSheetState extends State<_BranchDetailsSheet> {
  final _kb = HandleKeyboardService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial.name);
    _addressCtrl = TextEditingController(text: widget.initial.address ?? '');
    _phoneCtrl = TextEditingController(text: widget.initial.phone ?? '');
    _whatsappCtrl = TextEditingController(text: widget.initial.whatsapp ?? '');
    _lat = widget.initial.lat;
    _lng = widget.initial.lng;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  bool get _hasLocation => _lat != null && _lng != null;

  Future<void> _pickLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Loader.showError('tracking_location_denied'.tr);
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Loader.showError('tracking_location_denied'.tr);
      return;
    }
    Loader.show();
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      Loader.dismiss();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (_) {
      Loader.showError('home_loc_current_error'.tr);
    }
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('manager_branch_name_required'.tr);
      return;
    }
    Get.back();
    widget.onSave(
      widget.initial.copyWith(
        name: name,
        address: _orNull(_addressCtrl.text),
        phone: _orNull(_phoneCtrl.text),
        whatsapp: _orNull(_whatsappCtrl.text),
        lat: _lat,
        lng: _lng,
      ),
    );
  }

  String? _orNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: KeyboardActions(
          config: _kb.buildConfig(context, const []),
          disableScroll: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              AppText(
                text: 'manager_branch_edit'.tr,
                textStyle: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _nameCtrl,
                labelText: 'manager_branch_name'.tr,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _addressCtrl,
                labelText: 'manager_branch_address'.tr,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _phoneCtrl,
                labelText: 'manager_branch_phone'.tr,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _whatsappCtrl,
                labelText: 'manager_branch_whatsapp'.tr,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: _pickLocation,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.grayLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppText(
                          text: _hasLocation
                              ? '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                              : 'manager_branch_location_hint'.tr,
                          textStyle: context.typography.smRegular.copyWith(
                            color: _hasLocation
                                ? AppColors.textPrimaryParagraph
                                : AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ),
                      Icon(Icons.my_location_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              PrimaryTextButton(
                appButtonSize: AppButtonSize.large,
                onTap: _save,
                label: AppText(
                  text: 'manager_branch_save'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add sheet that creates a new branch together with its manager account
/// (branch name + manager name + manager phone), mirroring the setup flow.
class _AddBranchSheet extends StatefulWidget {
  final void Function(String branchName, String managerName, String phone)
      onSubmit;

  const _AddBranchSheet({required this.onSubmit});

  @override
  State<_AddBranchSheet> createState() => _AddBranchSheetState();
}

class _AddBranchSheetState extends State<_AddBranchSheet> {
  final _kb = HandleKeyboardService();
  final _branchCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  PhoneCountry _country = PhoneUtils.egypt;

  @override
  void dispose() {
    _branchCtrl.dispose();
    _managerCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final branchName = _branchCtrl.text.trim();
    final managerName = _managerCtrl.text.trim();
    final rawPhone = _phoneCtrl.text.trim();
    if (branchName.isEmpty) {
      Loader.showError('setup_owner_branch_name_required'.tr);
      return;
    }
    if (managerName.isEmpty) {
      Loader.showError('setup_manager_name_required'.tr);
      return;
    }
    if (!PhoneUtils.isValid(_country, rawPhone)) {
      Loader.showError('nursery_error_phone_invalid'.tr);
      return;
    }
    Get.back();
    widget.onSubmit(branchName, managerName, PhoneUtils.normalize(_country, rawPhone));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          14.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: KeyboardActions(
          config: _kb.buildConfig(context, const []),
          disableScroll: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              AppText(
                text: 'setup_add_branch_title'.tr,
                textStyle: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _branchCtrl,
                labelText: 'setup_branch_name_label'.tr,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _managerCtrl,
                labelText: 'setup_manager_name_label'.tr,
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 118.w,
                    child: CountryCodePicker(
                      value: _country,
                      fillColor: AppColors.white,
                      onChanged: (c) => setState(() => _country = c),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneCtrl,
                      labelText: 'setup_manager_phone_label'.tr,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              AppText(
                text: 'setup_manager_password_note'.tr,
                textStyle: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
              SizedBox(height: 20.h),
              PrimaryTextButton(
                appButtonSize: AppButtonSize.large,
                onTap: _submit,
                label: AppText(
                  text: 'setup_add_btn'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
