import '../../../../../index/index_main.dart';

class ParentCreateSheet extends StatefulWidget {
  const ParentCreateSheet({super.key});

  @override
  State<ParentCreateSheet> createState() => _ParentCreateSheetState();
}

class _ParentCreateSheetState extends State<ParentCreateSheet>
    with KeyboardSheetMixin {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _showPassword = false.obs;
  final _isLoading = false.obs;
  final _selectedChildIds = <String>[].obs;
  final _relationship = 'other'.obs;
  final _children = <ChildModel>[].obs;
  final _childrenLoading = true.obs;

  late final ParentAccountService _service;

  static final _phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

  @override
  void initState() {
    super.initState();
    _service = Get.find<ParentAccountService>();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    _childrenLoading.value = true;
    await Get.find<ChildParentService>().getAll(
      callBack: (list) {
        _children.value = list.whereType<ChildModel>().toList()
          ..sort((a, b) => a.firstName.compareTo(b.firstName));
      },
    );
    _childrenLoading.value = false;
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty) {
      Loader.showError('guardian_create_error_name'.tr);
      return;
    }
    if (!_phoneRegex.hasMatch(phone)) {
      Loader.showError('guardian_create_error_phone'.tr);
      return;
    }
    if (password.length < 6) {
      Loader.showError('guardian_create_error_password'.tr);
      return;
    }

    _isLoading.value = true;
    Loader.show();

    final ok = await _service.createAccount(
      name: name,
      phone: phone,
      password: password,
      childIds: List.from(_selectedChildIds),
      relationship: _relationship.value,
      onError: (msg) {
        _isLoading.value = false;
        Loader.showError(msg);
      },
    );

    if (ok) {
      _isLoading.value = false;
      Loader.showSuccess('guardian_create_success'.tr);
      await Future.delayed(const Duration(milliseconds: 900));
      Get.back(result: true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
              _SheetHandle(),
              SizedBox(height: 20.h),
              Text(
                'guardian_create_title'.tr,
                style: context.typography.mdBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 24.h),
              _SectionLabel('guardian_name_label'.tr),
              SizedBox(height: 6.h),
              _InputField(
                controller: _nameCtrl,
                hint: 'guardian_name_hint'.tr,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16.h),
              _SectionLabel('guardian_create_phone_label'.tr),
              SizedBox(height: 6.h),
              _InputField(
                controller: _phoneCtrl,
                hint: 'guardian_create_phone_hint'.tr,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              _SectionLabel('guardian_create_password_label'.tr),
              SizedBox(height: 6.h),
              _PasswordField(
                controller: _passwordCtrl,
                hint: 'guardian_create_password_hint'.tr,
                showPassword: _showPassword,
              ),
              SizedBox(height: 16.h),
              _SectionLabel('guardian_create_child_label'.tr),
              SizedBox(height: 6.h),
              _ChildMultiSelect(
                children: _children,
                isLoading: _childrenLoading,
                selectedIds: _selectedChildIds,
              ),
              SizedBox(height: 16.h),
              _SectionLabel('guardian_create_relationship_label'.tr),
              SizedBox(height: 6.h),
              _RelationshipDropdown(relationship: _relationship),
              SizedBox(height: 32.h),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading.value
                        ? SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'guardian_create_submit'.tr,
                            style: context.typography.smSemiBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
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

// ── Private widgets ───────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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
    style: context.typography.smRegular.copyWith(
      fontSize: 15,
      color: const Color(0xFF1E293B),
    ),
    decoration: _inputDecoration(hint),
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final RxBool showPassword;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.showPassword,
  });

  @override
  Widget build(BuildContext context) => Obx(
    () => TextField(
      inputFormatters: const [EnglishDigitsFormatter()],
      controller: controller,
      obscureText: !showPassword.value,
      style: context.typography.smRegular.copyWith(
        fontSize: 15,
        color: const Color(0xFF1E293B),
      ),
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            showPassword.value
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
          onPressed: showPassword.toggle,
        ),
      ),
    ),
  );
}

class _ChildMultiSelect extends StatelessWidget {
  final RxList<ChildModel> children;
  final RxBool isLoading;
  final RxList<String> selectedIds;

  const _ChildMultiSelect({
    required this.children,
    required this.isLoading,
    required this.selectedIds,
  });

  @override
  Widget build(BuildContext context) => Obx(() {
    if (isLoading.value) {
      return Container(
        height: 50.h,
        decoration: _dropdownDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 18.w,
            height: 18.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (children.isEmpty) {
      return Container(
        height: 50.h,
        decoration: _dropdownDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'guardian_create_child_none'.tr,
            style: context.typography.smRegular.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: _dropdownDecoration(),
      child: Column(
        children: children.map((c) {
          final id = c.key ?? '';
          final isSelected = selectedIds.contains(id);
          return InkWell(
            onTap: () {
              if (isSelected) {
                selectedIds.remove(id);
              } else {
                selectedIds.add(id);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFCBD5E1),
                        width: 1.8,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${c.firstName} ${c.lastName}',
                    style: context.typography.smRegular.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  });
}

class _RelationshipDropdown extends StatelessWidget {
  final RxString relationship;
  const _RelationshipDropdown({required this.relationship});

  @override
  Widget build(BuildContext context) => Obx(
    () => Container(
      decoration: _dropdownDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: relationship.value,
          isExpanded: true,
          style: context.typography.smRegular.copyWith(
            fontSize: 15,
            color: const Color(0xFF1E293B),
          ),
          items: [
            DropdownMenuItem(
              value: 'father',
              child: Text('guardian_create_relationship_father'.tr),
            ),
            DropdownMenuItem(
              value: 'mother',
              child: Text('guardian_create_relationship_mother'.tr),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Text('guardian_create_relationship_other'.tr),
            ),
          ],
          onChanged: (v) {
            if (v != null) relationship.value = v;
          },
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
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
    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
  ),
);

BoxDecoration _dropdownDecoration() => BoxDecoration(
  color: const Color(0xFFF8FAFC),
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: const Color(0xFFE2E8F0)),
);
