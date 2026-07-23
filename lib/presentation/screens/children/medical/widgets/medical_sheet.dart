import '../../../../../index/index_main.dart';

class MedicalSheet extends StatefulWidget {
  final MedicalProfileModel? initial;
  const MedicalSheet({super.key, this.initial});

  @override
  State<MedicalSheet> createState() => _MedicalSheetState();
}

class _MedicalSheetState extends State<MedicalSheet> with KeyboardSheetMixin {
  late final MedicalProfileParentService _service;
  late final ChildParentService _childService;

  List<ChildModel> _children = [];
  String? _childId;
  String? _bloodType;
  final emergencyContactCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();
  final doctorCtrl = TextEditingController();
  final doctorPhoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final allergyCtrl = TextEditingController();
  final medicationCtrl = TextEditingController();
  List<String> _allergies = [];
  List<String> _medications = [];
  bool _loading = true;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<MedicalProfileParentService>();
    _childService = Get.find<ChildParentService>();
    if (isEdit) {
      _childId = widget.initial!.childId;
      _bloodType = widget.initial!.bloodType;
      emergencyContactCtrl.text = widget.initial!.emergencyContact ?? '';
      emergencyPhoneCtrl.text = widget.initial!.emergencyPhone ?? '';
      doctorCtrl.text = widget.initial!.doctorName ?? '';
      doctorPhoneCtrl.text = widget.initial!.doctorPhone ?? '';
      notesCtrl.text = widget.initial!.notes ?? '';
      _allergies = List.from(widget.initial!.allergies);
      _medications = List.from(widget.initial!.medications);
    }
    _childService.getAll(
      callBack: (list) {
        if (mounted)
          setState(() {
            _children = list.whereType<ChildModel>().toList();
            _loading = false;
          });
      },
    );
  }

  @override
  void dispose() {
    emergencyContactCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    doctorCtrl.dispose();
    doctorPhoneCtrl.dispose();
    notesCtrl.dispose();
    allergyCtrl.dispose();
    medicationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_childId == null) {
      Loader.showError('medical_error_child'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit
        ? (widget.initial!.key ?? const Uuid().v4())
        : const Uuid().v4();
    final item = MedicalProfileModel(
      key: id,
      childId: _childId!,
      nurseryId: nurseryId,
      allergies: _allergies,
      medications: _medications,
      bloodType: _bloodType,
      emergencyContact: emergencyContactCtrl.text.trim().isEmpty
          ? null
          : emergencyContactCtrl.text.trim(),
      emergencyPhone: emergencyPhoneCtrl.text.trim().isEmpty
          ? null
          : emergencyPhoneCtrl.text.trim(),
      doctorName: doctorCtrl.text.trim().isEmpty
          ? null
          : doctorCtrl.text.trim(),
      doctorPhone: doctorPhoneCtrl.text.trim().isEmpty
          ? null
          : doctorPhoneCtrl.text.trim(),
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: item,
        callBack: (s) {
          Loader.dismiss();
          if (s == ResponseStatus.success) {
            Loader.showSuccess('medical_success_updated'.tr);
            Get.back();
          } else
            Loader.showError('medical_error_failed'.tr);
        },
      );
    } else {
      await _service.add(
        item: item,
        callBack: (s) {
          Loader.dismiss();
          if (s == ResponseStatus.success) {
            Loader.showSuccess('medical_success_added'.tr);
            Get.back();
          } else
            Loader.showError('medical_error_failed'.tr);
        },
      );
    }
  }

  void _addAllergy() {
    final v = allergyCtrl.text.trim();
    if (v.isNotEmpty && !_allergies.contains(v)) {
      setState(() {
        _allergies.add(v);
        allergyCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
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
              Text(
                isEdit ? 'medical_edit_title'.tr : 'medical_add_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 24.h),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _Label('medical_child_label'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<ChildModel>(
                  value: _children.where((c) => c.key == _childId).firstOrNull,
                  hint: Text(
                    'medical_child_hint'.tr,
                    style: context.typography.smRegular.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 14,
                    ),
                  ),
                  onChanged: (c) => setState(() => _childId = c?.key),
                  items: _children
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.firstName} ${c.lastName}'),
                        ),
                      )
                      .toList(),
                  decoration: _dropDecoration(),
                ),
                SizedBox(height: 16.h),
                _Label('medical_blood_type'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String>(
                  value: _bloodType,
                  hint: Text(
                    'medical_blood_type_hint'.tr,
                    style: context.typography.smRegular.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 14,
                    ),
                  ),
                  onChanged: (v) => setState(() => _bloodType = v),
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  decoration: _dropDecoration(),
                ),
                SizedBox(height: 16.h),
                _Label('medical_allergies'.tr),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: allergyCtrl,
                        hint: 'medical_allergy_hint'.tr,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _addAllergy,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                if (_allergies.isNotEmpty)
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: _allergies
                        .map(
                          (a) => Chip(
                            label: Text(
                              a,
                              style: context.typography.xsRegular.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            deleteIcon: Icon(Icons.close, size: 14.sp),
                            onDeleted: () =>
                                setState(() => _allergies.remove(a)),
                            backgroundColor: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.1),
                          ),
                        )
                        .toList(),
                  ),
                SizedBox(height: 16.h),
                _Label('medical_emergency_contact'.tr),
                SizedBox(height: 6.h),
                _Field(
                  controller: emergencyContactCtrl,
                  hint: 'medical_emergency_contact_hint'.tr,
                ),
                SizedBox(height: 12.h),
                _Field(
                  controller: emergencyPhoneCtrl,
                  hint: 'medical_emergency_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),
                _Label('medical_doctor_label'.tr),
                SizedBox(height: 6.h),
                _Field(controller: doctorCtrl, hint: 'medical_doctor_hint'.tr),
                SizedBox(height: 12.h),
                _Field(
                  controller: doctorPhoneCtrl,
                  hint: 'medical_doctor_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),
                _Label('medical_notes_label'.tr),
                SizedBox(height: 6.h),
                _Field(
                  controller: notesCtrl,
                  hint: 'medical_notes_hint'.tr,
                  maxLines: 3,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'medical_save'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropDecoration() => InputDecoration(
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
  );
}

class _Handle extends StatelessWidget {
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.smMedium.copyWith(
      fontSize: 14,
      color: const Color(0xFF475569),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
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
