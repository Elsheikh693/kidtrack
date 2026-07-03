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
/// date of birth, detailed address, blood type and nationality — the four
/// fields stored directly on [ChildModel].
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
  bool _saving = false;

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
    final c = widget.child;
    if (c.dateOfBirth != null) {
      _dob = DateTime.fromMillisecondsSinceEpoch(c.dateOfBirth!);
    }
    _bloodType = _bloodTypes.contains(c.bloodType) ? c.bloodType : null;
    _addressCtrl.text = c.homeAddress ?? '';
    // Default new children to the most common nationality; keep any existing.
    _nationality = (c.nationality?.trim().isNotEmpty ?? false)
        ? c.nationality!.trim()
        : _defaultNationality;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _dob != null &&
      _bloodType != null &&
      _addressCtrl.text.trim().isNotEmpty &&
      (_nationality?.trim().isNotEmpty ?? false);

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

    final updated = widget.child.copyWith(
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
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
                      Icons.child_care_rounded,
                      color: AppColors.primary,
                      size: 38.sp,
                    ),
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

                // ── Date of birth ──────────────────────────────────────────
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

                // ── Detailed address ───────────────────────────────────────
                _FieldLabel('child_profile_address'.tr),
                SizedBox(height: 8.h),
                _TextInput(
                  controller: _addressCtrl,
                  hint: 'child_details_address_hint'.tr,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 18.h),

                // ── Blood type ─────────────────────────────────────────────
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
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _bloodType = v),
                ),
                SizedBox(height: 18.h),

                // ── Nationality ────────────────────────────────────────────
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
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _nationality = v),
                ),
                SizedBox(height: 28.h),

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
                if (!widget.mandatory) ...[
                  SizedBox(height: 6.h),
                  Center(
                    child: TextButton(
                      onPressed: _saving ? null : Get.back,
                      child: Text(
                        'common_cancel'.tr,
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.grayMedium),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
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
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
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

/// Enforces the "complete your child's profile on first login" rule. The four
/// core fields (DOB, address, blood type, nationality) live on [ChildModel];
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
