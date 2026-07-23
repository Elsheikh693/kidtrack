import 'dart:io';

import '../../../index/index_main.dart';

const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

const _defaultNationality = 'مصري';
const _nationalities = [
  'مصري',
  'سعودي',
  'إماراتي',
  'كويتي',
  'قطري',
  'بحريني',
  'عُماني',
  'أردني',
  'فلسطيني',
  'لبناني',
  'سوري',
  'عراقي',
  'يمني',
  'سوداني',
  'ليبي',
  'تونسي',
  'جزائري',
  'مغربي',
  'أخرى',
];

/// Bottom sheet where the parent completes / edits their child's core profile:
/// profile photo, date of birth, detailed address, blood type and nationality —
/// the fields stored directly on [ChildModel].
///
/// In [mandatory] mode the sheet is non-dismissible (no close, no drag, back
/// disabled) and is shown on the parent's first login when any field is empty.
/// In edit mode it is dismissible and pre-filled with the current values.
class ChildDetailsSheet extends StatefulWidget {
  final ChildModel child;
  final bool mandatory;
  final VoidCallback? onSaved;

  const ChildDetailsSheet({
    super.key,
    required this.child,
    this.mandatory = false,
    this.onSaved,
  });

  @override
  State<ChildDetailsSheet> createState() => _ChildDetailsSheetState();
}

class _ChildDetailsSheetState extends State<ChildDetailsSheet> {
  DateTime? _dob;
  String? _bloodType;
  String? _nationality;
  final _addressCtrl = TextEditingController();
  // Child identity fields — only editable in edit mode (hidden in the parent's
  // mandatory first-login completion, where the name is already set).
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  String _gender = 'male';
  File? _pickedImage;
  bool _saving = false;

  /// Whether the identity fields (name + gender) are shown & editable.
  bool get _canEditIdentity => !widget.mandatory;

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  /// Nationality options, guaranteeing the child's current value is selectable
  /// even if it isn't one of the defaults.
  List<String> get _nationalityItems {
    final current = _nationality?.trim() ?? '';
    if (current.isEmpty || _nationalities.contains(current)) {
      return _nationalities;
    }
    return [current, ..._nationalities];
  }

  @override
  void initState() {
    super.initState();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('child_details', 1);
    final c = widget.child;
    if (c.dateOfBirth != null) {
      _dob = DateTime.fromMillisecondsSinceEpoch(c.dateOfBirth!);
    }
    _bloodType = _bloodTypes.contains(c.bloodType) ? c.bloodType : null;
    _addressCtrl.text = c.homeAddress ?? '';
    _nameCtrl.text = '${c.firstName} ${c.lastName}'.trim();
    _gender = (c.gender == 'female') ? 'female' : 'male';
    // Default new children to the most common nationality; keep any existing.
    _nationality = (c.nationality?.trim().isNotEmpty ?? false)
        ? c.nationality!.trim()
        : _defaultNationality;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  /// A photo is present when the parent just picked one, or the child already
  /// has one stored — either satisfies the mandatory-photo rule.
  bool get _hasPhoto => _pickedImage != null || widget.child.hasImage;

  bool get _isValid =>
      _hasPhoto &&
      _dob != null &&
      _bloodType != null &&
      _addressCtrl.text.trim().isNotEmpty &&
      (_nationality?.trim().isNotEmpty ?? false) &&
      (!_canEditIdentity || _nameCtrl.text.trim().isNotEmpty);

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();
    await PickedImage().pickImage(
      callBack: (file) async {
        if (file != null && mounted) setState(() => _pickedImage = file);
      },
    );
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _dob ?? DateTime(now.year - 3, now.month, now.day),
      minimumDate: DateTime(now.year - 12),
      maximumDate: now,
      showTodayButton: false,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    Loader.show();

    // Upload the freshly picked photo first; abort the save if it fails so we
    // never persist child data with a missing (mandatory) photo.
    var imageUrl = widget.child.profileImage;
    if (_pickedImage != null) {
      imageUrl = await Get.find<ChildParentService>().uploadProfileImage(
        nurseryId: widget.child.nurseryId,
        childId: widget.child.key ?? '',
        file: _pickedImage!,
      );
      if (imageUrl == null) {
        Loader.dismiss();
        if (mounted) setState(() => _saving = false);
        Loader.showError('child_details_photo_upload_failed'.tr);
        return;
      }
    }

    // Split the single name field back into first/last, mirroring registration.
    String firstName = widget.child.firstName;
    String lastName = widget.child.lastName;
    if (_canEditIdentity) {
      final parts = _nameCtrl.text.trim().split(RegExp(r'\s+'));
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final updated = widget.child.copyWith(
      firstName: firstName,
      lastName: lastName,
      gender: _canEditIdentity ? _gender : widget.child.gender,
      profileImage: imageUrl,
      dateOfBirth: _dob!.millisecondsSinceEpoch,
      bloodType: _bloodType,
      nationality: _nationality!.trim(),
      homeAddress: _addressCtrl.text.trim(),
    );

    await Get.find<ChildParentService>().update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          widget.onSaved?.call();
          Get.back();
          Loader.showSuccess('child_details_saved'.tr);
        } else {
          if (mounted) setState(() => _saving = false);
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: KeyboardActions(
          config: _keyboardService.buildConfig(context, _keys),
          disableScroll: true,
          child: Column(
            children: [
              // ── Grabber ────────────────────────────────────────────────
              SizedBox(height: 12.h),
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
              // ── Scrollable content ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _PhotoPicker(
                          file: _pickedImage,
                          imageUrl: widget.child.profileImage,
                          onTap: _pickImage,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: Text(
                          widget.mandatory
                              ? 'child_details_complete_title'.tr
                              : 'child_details_edit_title'.tr,
                          style: context.typography.lgBold
                              .copyWith(color: AppColors.textDefault),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: Text(
                          widget.mandatory
                              ? 'child_details_complete_subtitle'
                                  .trParams({'name': widget.child.firstName})
                              : 'child_details_edit_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: context.typography.smRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Name + gender (edit mode only) ───────────────────
                      if (_canEditIdentity) ...[
                        _FieldLabel('child_name_label'.tr),
                        SizedBox(height: 8.h),
                        _TextInput(
                          controller: _nameCtrl,
                          hint: 'child_name_hint'.tr,
                          icon: Icons.person_outline_rounded,
                          focusNode: _nameFocus,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 18.h),
                        _FieldLabel('child_gender_label'.tr),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: context.typography.smMedium
                              .copyWith(color: AppColors.textDefault),
                          decoration: _inputDecoration(
                            context,
                            prefixIcon: Icons.wc_outlined,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('child_gender_male'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('child_gender_female'.tr),
                            ),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? _gender),
                        ),
                        SizedBox(height: 18.h),
                      ],

                      // ── Date of birth ────────────────────────────────────
                      _FieldLabel('child_profile_dob'.tr),
                      SizedBox(height: 8.h),
                      _TapField(
                        icon: Icons.cake_outlined,
                        text: _dob != null
                            ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                            : 'child_details_dob_hint'.tr,
                        isPlaceholder: _dob == null,
                        onTap: _pickDob,
                      ),
                      SizedBox(height: 18.h),

                      // ── Detailed address ─────────────────────────────────
                      _FieldLabel('child_profile_address'.tr),
                      SizedBox(height: 8.h),
                      _TextInput(
                        controller: _addressCtrl,
                        hint: 'child_details_address_hint'.tr,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        focusNode: _keyboardService.getFocusNode(_keys[0]),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 18.h),

                      // ── Blood type ───────────────────────────────────────
                      _FieldLabel('child_profile_blood_type'.tr),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: _bloodType,
                        isExpanded: true,
                        hint: Text(
                          'child_details_blood_type_hint'.tr,
                          style: context.typography.smRegular
                              .copyWith(color: AppColors.grayMedium),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.textDefault),
                        decoration: _inputDecoration(
                          context,
                          prefixIcon: Icons.bloodtype_outlined,
                        ),
                        items: _bloodTypes
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _bloodType = v),
                      ),
                      SizedBox(height: 18.h),

                      // ── Nationality ──────────────────────────────────────
                      _FieldLabel('child_profile_nationality'.tr),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: _nationality,
                        isExpanded: true,
                        hint: Text(
                          'child_details_nationality_hint'.tr,
                          style: context.typography.smRegular
                              .copyWith(color: AppColors.grayMedium),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.textDefault),
                        decoration: _inputDecoration(
                          context,
                          prefixIcon: Icons.flag_outlined,
                        ),
                        items: _nationalityItems
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _nationality = v),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Pinned actions ─────────────────────────────────────────
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isValid && !_saving) ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.4),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'child_details_save'.tr,
                            style: context.typography.smSemiBold
                                .copyWith(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                      if (!widget.mandatory)
                        TextButton(
                          onPressed: _saving ? null : Get.back,
                          child: Text(
                            'common_cancel'.tr,
                            style: context.typography.smMedium
                                .copyWith(color: AppColors.grayMedium),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular tappable avatar used to pick / preview the child's mandatory photo.
class _PhotoPicker extends StatelessWidget {
  final File? file;
  final String? imageUrl;
  final VoidCallback onTap;

  const _PhotoPicker({
    required this.file,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = file != null || (imageUrl?.isNotEmpty ?? false);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: file != null
                    ? Image.file(file!, fit: BoxFit.cover)
                    : (imageUrl?.isNotEmpty ?? false)
                        ? AppNetworkImage(
                            url: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: _placeholder(),
                          )
                        : _placeholder(),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          hasImage
              ? 'child_details_photo_change'.tr
              : 'child_details_photo_hint'.tr,
          style: context.typography.xsMedium.copyWith(
            color: hasImage ? AppColors.primary : AppColors.errorForeground,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Icon(
        Icons.add_a_photo_rounded,
        color: AppColors.primary,
        size: 34.sp,
      );
}

InputDecoration _inputDecoration(BuildContext context, {IconData? prefixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.backgroundNeutral100,
    prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: AppColors.grayMedium) : null,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
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
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.typography.smSemiBold
            .copyWith(color: AppColors.textSecondaryParagraph),
      );
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      style: context.typography.smMedium.copyWith(color: AppColors.textDefault),
      decoration: _inputDecoration(context, prefixIcon: icon).copyWith(
        hintText: hint,
        hintStyle:
            context.typography.smRegular.copyWith(color: AppColors.grayMedium),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _TapField({
    required this.icon,
    required this.text,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grayMedium),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: (isPlaceholder
                        ? context.typography.smRegular
                            .copyWith(color: AppColors.grayMedium)
                        : context.typography.smMedium
                            .copyWith(color: AppColors.textDefault)),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}

/// Opens the child-details sheet. When [mandatory] is true the sheet cannot be
/// dismissed until the parent fills every field and saves.
Future<void> showChildDetailsSheet({
  required ChildModel child,
  bool mandatory = false,
  VoidCallback? onSaved,
}) {
  return Get.bottomSheet(
    PopScope(
      canPop: !mandatory,
      child: ChildDetailsSheet(
        child: child,
        mandatory: mandatory,
        onSaved: onSaved,
      ),
    ),
    isScrollControlled: true,
    isDismissible: !mandatory,
    enableDrag: !mandatory,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}

/// Enforces the "complete your child's profile on first login" rule. The core
/// fields (photo, DOB, address, blood type, nationality) live on [ChildModel];
/// when any is missing the parent is shown a mandatory sheet before they can
/// use the app.
class ChildProfileCompletionPrompt {
  static bool _showing = false;

  /// Shows the mandatory sheet for the active child when its profile is
  /// incomplete. Safe to call multiple times — it no-ops while already
  /// showing, and once the data is saved the completeness check passes.
  static Future<void> maybeShow() async {
    if (_showing) return;
    if (!SessionService().isParent) return;
    final childId = Get.find<ActiveChildService>().childId.value;
    if (childId.isEmpty) return;

    final child = await _fetchChild(childId);
    if (child == null || _isComplete(child)) return;
    if (_showing) return;

    _showing = true;
    await showChildDetailsSheet(child: child, mandatory: true);
    _showing = false;
  }

  /// Whether the active child's core profile is fully filled. Used to hold back
  /// other first-open prompts (e.g. the nursery rating) until onboarding data
  /// is complete. Returns false when the child isn't loaded yet (so a later
  /// prompt waits), true on a fetch failure (so we never block indefinitely).
  static Future<bool> isActiveChildComplete() async {
    final childId = Get.find<ActiveChildService>().childId.value;
    if (childId.isEmpty) return false;
    final child = await _fetchChild(childId);
    if (child == null) return true;
    return _isComplete(child);
  }

  static bool _isComplete(ChildModel c) =>
      c.hasImage &&
      c.dateOfBirth != null &&
      (c.bloodType?.trim().isNotEmpty ?? false) &&
      (c.nationality?.trim().isNotEmpty ?? false) &&
      (c.homeAddress?.trim().isNotEmpty ?? false);

  static Future<ChildModel?> _fetchChild(String id) async {
    ChildModel? found;
    await Get.find<ChildParentService>().getAll(callBack: (list) {
      found = list
          .whereType<ChildModel>()
          .where((c) => c.key == id)
          .firstOrNull;
    });
    return found;
  }
}
