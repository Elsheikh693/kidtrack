import '../../../../../index/index_main.dart';

class GuardianSheet extends StatefulWidget {
  final ParentModel initial;
  const GuardianSheet({super.key, required this.initial});

  @override
  State<GuardianSheet> createState() => _GuardianSheetState();
}

class _GuardianSheetState extends State<GuardianSheet> with KeyboardSheetMixin {
  late final GuardianParentService _service;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = Get.find<GuardianParentService>();
    nameCtrl.text = widget.initial.name;
    phoneCtrl.text = widget.initial.phone ?? '';
    emailCtrl.text = widget.initial.email ?? '';
  }

  @override
  void dispose() { nameCtrl.dispose(); phoneCtrl.dispose(); emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) { Loader.showError('guardian_error_name'.tr); return; }
    final item = widget.initial.copyWith(
      name: name,
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
    );
    Loader.show();
    await _service.update(item: item, callBack: (s) {
      Loader.dismiss();
      if (s == ResponseStatus.success) { Loader.showSuccess('guardian_success_updated'.tr); Get.back(); }
      else Loader.showError('guardian_error_failed'.tr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Handle(),
              SizedBox(height: 20.h),
              Text('guardian_edit_title'.tr, style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),
              _Label('guardian_name_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: nameCtrl, hint: 'guardian_name_hint'.tr),
              SizedBox(height: 16.h),
              _Label('guardian_phone_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: phoneCtrl, hint: 'guardian_phone_hint'.tr, keyboardType: TextInputType.phone),
              SizedBox(height: 16.h),
              _Label('guardian_email_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: emailCtrl, hint: 'guardian_email_hint'.tr, keyboardType: TextInputType.emailAddress),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0),
                  child: Text('guardian_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4.r))));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboardType,
    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: hint, hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
      filled: true, fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    ),
  );
}
