import '../../../../../index/index_main.dart';

class PickupSheet extends StatefulWidget {
  final AuthorizedPickupModel? initial;
  const PickupSheet({super.key, this.initial});

  @override
  State<PickupSheet> createState() => _PickupSheetState();
}

class _PickupSheetState extends State<PickupSheet> with KeyboardSheetMixin {
  late final AuthorizedPickupParentService _service;
  late final ChildParentService _childService;

  List<ChildModel> _children = [];
  String? _childId;
  String _relationship = 'other';
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  bool _loading = true;

  bool get isEdit => widget.initial != null;
  final _relationships = [
    'father',
    'mother',
    'grandfather',
    'grandmother',
    'uncle',
    'aunt',
    'driver',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _service = Get.find<AuthorizedPickupParentService>();
    _childService = Get.find<ChildParentService>();
    if (isEdit) {
      _childId = widget.initial!.childId;
      _relationship = widget.initial!.relationship;
      nameCtrl.text = widget.initial!.name;
      phoneCtrl.text = widget.initial!.phone ?? '';
      idCtrl.text = widget.initial!.idNumber ?? '';
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
    nameCtrl.dispose();
    phoneCtrl.dispose();
    idCtrl.dispose();
    super.dispose();
  }

  String _relLabel(String r) {
    switch (r) {
      case 'father':
        return 'pickup_rel_father'.tr;
      case 'mother':
        return 'pickup_rel_mother'.tr;
      case 'grandfather':
        return 'pickup_rel_grandfather'.tr;
      case 'grandmother':
        return 'pickup_rel_grandmother'.tr;
      case 'uncle':
        return 'pickup_rel_uncle'.tr;
      case 'aunt':
        return 'pickup_rel_aunt'.tr;
      case 'driver':
        return 'pickup_rel_driver'.tr;
      default:
        return 'pickup_rel_other'.tr;
    }
  }

  Future<void> _submit() async {
    if (_childId == null) {
      Loader.showError('pickup_error_child'.tr);
      return;
    }
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('pickup_error_name'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit
        ? (widget.initial!.key ?? const Uuid().v4())
        : const Uuid().v4();
    final item = AuthorizedPickupModel(
      key: id,
      nurseryId: nurseryId,
      childId: _childId!,
      name: name,
      relationship: _relationship,
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      idNumber: idCtrl.text.trim().isEmpty ? null : idCtrl.text.trim(),
      isActive: widget.initial?.isActive ?? true,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: item,
        callBack: (s) {
          Loader.dismiss();
          if (s == ResponseStatus.success) {
            Loader.showSuccess('pickup_success_updated'.tr);
            Get.back();
          } else
            Loader.showError('pickup_error_failed'.tr);
        },
      );
    } else {
      await _service.add(
        item: item,
        callBack: (s) {
          Loader.dismiss();
          if (s == ResponseStatus.success) {
            Loader.showSuccess('pickup_success_added'.tr);
            Get.back();
          } else
            Loader.showError('pickup_error_failed'.tr);
        },
      );
    }
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
              Text(
                isEdit ? 'pickup_edit_title'.tr : 'pickup_add_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 24.h),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _Label('pickup_child_label'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<ChildModel>(
                  value: _children.where((c) => c.key == _childId).firstOrNull,
                  hint: Text(
                    'pickup_child_hint'.tr,
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
                  decoration: _dec(),
                ),
                SizedBox(height: 16.h),
                _Label('pickup_name_label'.tr),
                SizedBox(height: 6.h),
                _Field(controller: nameCtrl, hint: 'pickup_name_hint'.tr),
                SizedBox(height: 16.h),
                _Label('pickup_relationship_label'.tr),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String>(
                  value: _relationship,
                  onChanged: (v) =>
                      setState(() => _relationship = v ?? 'other'),
                  items: _relationships
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(_relLabel(r)),
                        ),
                      )
                      .toList(),
                  decoration: _dec(),
                ),
                SizedBox(height: 16.h),
                _Label('pickup_phone_label'.tr),
                SizedBox(height: 6.h),
                _Field(
                  controller: phoneCtrl,
                  hint: 'pickup_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),
                _Label('pickup_id_label'.tr),
                SizedBox(height: 6.h),
                _Field(controller: idCtrl, hint: 'pickup_id_hint'.tr),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'pickup_save'.tr,
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

  InputDecoration _dec() => InputDecoration(
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
  const _Field({
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
