import '../../../../../index/index_main.dart';

class BranchSheet extends StatefulWidget {
  final BranchModel? initial;
  const BranchSheet({super.key, this.initial});

  @override
  State<BranchSheet> createState() => _BranchSheetState();
}

class _BranchSheetState extends State<BranchSheet> with KeyboardSheetMixin {
  late final BranchParentService _service;

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();

  bool get isEdit => widget.initial != null;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _service = Get.find<BranchParentService>();
    if (isEdit) {
      nameCtrl.text = widget.initial!.name;
      addressCtrl.text = widget.initial!.address ?? '';
      phoneCtrl.text = widget.initial!.phone ?? '';
      capacityCtrl.text = widget.initial!.capacity?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('branch_error_name_required'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit
        ? (widget.initial!.key ?? const Uuid().v4())
        : const Uuid().v4();
    final branch = BranchModel(
      key: id,
      nurseryId: nurseryId,
      name: name,
      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      capacity: int.tryParse(capacityCtrl.text.trim()),
      isActive: widget.initial?.isActive ?? true,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: branch,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('branch_success_updated'.tr);
            Get.back();
          } else {
            Loader.showError('branch_error_failed'.tr);
          }
        },
      );
    } else {
      await _service.add(
        item: branch,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('branch_success_added'.tr);
            Get.back();
          } else {
            Loader.showError('branch_error_failed'.tr);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        // Cap the height so the sheet hugs its content (Column.min) and never
        // reaches the status bar. The field area scrolls if it grows past the
        // cap or when the keyboard opens.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            _SheetHandle(),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child:
                  _SheetTitle(text: isEdit ? 'branch_edit'.tr : 'branch_add'.tr),
            ),
            SizedBox(height: 24.h),
            Flexible(
              child: wrapWithKeyboard(
                context: context,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('branch_name_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                          controller: nameCtrl, hint: 'branch_name_hint'.tr),
                      SizedBox(height: 16.h),
                      _FieldLabel('branch_address_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: addressCtrl,
                        hint: 'branch_address_hint'.tr,
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('branch_phone_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: phoneCtrl,
                        hint: 'branch_phone_hint'.tr,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('branch_capacity_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: capacityCtrl,
                        hint: 'branch_capacity_hint'.tr,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 32.h),
                      _SubmitButton(
                        label: isEdit ? 'branch_save'.tr : 'branch_save'.tr,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sheet helpers ──────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r),
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  final String text;
  const _SheetTitle({required this.text});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.lgBold.copyWith(
      fontSize: 18,
      color: const Color(0xFF1E293B),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.smMedium.copyWith(
      fontSize: 14,
      color: const Color(0xFF475569),
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: controller,
    keyboardType: keyboardType,
    maxLines: 1,
    style: context.typography.smRegular.copyWith(
      fontSize: 15,
      color: const Color(0xFF1E293B),
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(
        color: const Color(0xFFCBD5E1),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SubmitButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52.h,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: context.typography.smSemiBold.copyWith(fontSize: 16),
      ),
    ),
  );
}
