import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../../index/index_main.dart';
import '../location_picker_view.dart';

/// Manager-side editor for the nursery's branches.
/// Lists existing branches with edit/delete and an "add branch" button that
/// opens a form sheet.
class ProfileBranchesEditor extends StatelessWidget {
  const ProfileBranchesEditor({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  void _openForm({int? index}) {
    final existing = index != null ? controller.branches[index] : null;
    Get.bottomSheet(
      _BranchFormSheet(
        initial: existing,
        onSave: (branch) {
          if (index != null) {
            controller.updateBranch(index, branch);
          } else {
            controller.addBranch(branch);
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < controller.branches.length; i++) ...[
            _BranchTile(
              branch: controller.branches[i],
              onEdit: () => _openForm(index: i),
              onDelete: () => controller.removeBranch(i),
            ),
            SizedBox(height: 10.h),
          ],
          GestureDetector(
            onTap: () => _openForm(),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.primary40,
                  width: 1,
                ),
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
  final NurseryBranch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchTile({
    required this.branch,
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
                AppText(
                  text: branch.name,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                ),
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

class _BranchFormSheet extends StatefulWidget {
  final NurseryBranch? initial;
  final void Function(NurseryBranch) onSave;

  const _BranchFormSheet({this.initial, required this.onSave});

  @override
  State<_BranchFormSheet> createState() => _BranchFormSheetState();
}

class _BranchFormSheetState extends State<_BranchFormSheet> {
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
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.initial?.address ?? '');
    _phoneCtrl = TextEditingController(text: widget.initial?.phone ?? '');
    _whatsappCtrl =
        TextEditingController(text: widget.initial?.whatsapp ?? '');
    _lat = widget.initial?.lat;
    _lng = widget.initial?.lng;
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
    final initial =
        _hasLocation ? gmap.LatLng(_lat!, _lng!) : null;
    final result = await Get.to<gmap.LatLng>(
      () => LocationPickerView(initial: initial),
    );
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('manager_branch_name_required'.tr);
      return;
    }
    widget.onSave(
      NurseryBranch(
        name: name,
        address: _orNull(_addressCtrl.text),
        phone: _orNull(_phoneCtrl.text),
        whatsapp: _orNull(_whatsappCtrl.text),
        lat: _lat,
        lng: _lng,
      ),
    );
    Get.back();
  }

  String? _orNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
              text: widget.initial == null
                  ? 'manager_branch_add'.tr
                  : 'manager_branch_edit'.tr,
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
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.grayMedium),
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
