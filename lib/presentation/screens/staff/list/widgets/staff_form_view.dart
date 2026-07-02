import '../../../../../index/index_main.dart';

class StaffFormView extends StatefulWidget {
  const StaffFormView({super.key});

  @override
  State<StaffFormView> createState() => _StaffFormViewState();
}

class _StaffFormViewState extends State<StaffFormView> {
  late final StaffFormController controller;

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffFormController>();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          title: Obx(
            () => Text(
              (controller.isEdit.value
                      ? 'staff_form_edit_title'
                      : 'staff_form_add_title')
                  .tr,
              style: context.typography.lgBold.copyWith(
                color: const Color(0xFF1E293B),
                fontSize: 18,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                _FieldLabel('staff_form_name_label'.tr),
                SizedBox(height: 6.h),
                _InputField(
                  controller: controller.nameCtrl,
                  hint: 'staff_form_name_hint'.tr,
                  keyboardType: TextInputType.name,
                  focusNode: _nameFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                SizedBox(height: 16.h),

                // Phone
                _FieldLabel('staff_form_phone_label'.tr),
                SizedBox(height: 6.h),
                _InputField(
                  controller: controller.phoneCtrl,
                  hint: 'staff_form_phone_hint'.tr,
                  keyboardType: TextInputType.phone,
                  focusNode: _phoneFocus,
                  textInputAction: controller.isEdit.value
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    if (!controller.isEdit.value) {
                      _passwordFocus.requestFocus();
                    } else {
                      _phoneFocus.unfocus();
                    }
                  },
                ),
                SizedBox(height: 16.h),

                // Password (create only)
                Obx(() {
                  if (controller.isEdit.value) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('staff_form_password_label'.tr),
                      SizedBox(height: 6.h),
                      Obx(
                        () => _PasswordField(
                          controller: controller.passwordCtrl,
                          focusNode: _passwordFocus,
                          showPassword: controller.showPassword.value,
                          onToggle: controller.showPassword.toggle,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                }),

                // Template
                _FieldLabel('staff_form_template_label'.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _Dropdown<StaffTemplate>(
                    value: controller.selectedTemplate.value,
                    items: StaffTemplate.values,
                    itemLabel: (t) => t.labelKey.tr,
                    onChanged: (t) {
                      if (t != null) controller.selectedTemplate.value = t;
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // Branch
                _FieldLabel('staff_form_branch_label'.tr),
                SizedBox(height: 6.h),
                Obx(() {
                  if (controller.branches.isEmpty) {
                    return _DisabledDropdown('staff_form_no_branches'.tr);
                  }
                  return _Dropdown<BranchModel?>(
                    value: controller.selectedBranch.value,
                    items: [null, ...controller.branches],
                    itemLabel: (b) =>
                        b == null ? 'staff_form_no_branch'.tr : b.name,
                    onChanged: (b) => controller.selectedBranch.value = b,
                  );
                }),
                SizedBox(height: 16.h),

                // Shift
                _FieldLabel('staff_form_shift_label'.tr),
                SizedBox(height: 6.h),
                Obx(
                  () => _Dropdown<String>(
                    value: controller.selectedShift.value,
                    items: const ['morning', 'evening', 'both'],
                    itemLabel: (s) => 'shift_$s'.tr,
                    onChanged: (s) {
                      if (s != null) controller.selectedShift.value = s;
                    },
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Obx(
                      () => Text(
                        (controller.isEdit.value
                                ? 'staff_form_submit_edit'
                                : 'staff_form_submit_add')
                            .tr,
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
      ),
    );
  }
}

// ── Private helpers — one class each, private to this file ───────────────────

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
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
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
    ),
  );
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool showPassword;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.showPassword,
    required this.onToggle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    obscureText: !showPassword,
    textInputAction: TextInputAction.done,
    onSubmitted: (_) => focusNode?.unfocus(),
    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: 'staff_form_password_hint'.tr,
      hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      suffixIcon: IconButton(
        icon: Icon(
          showPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: const Color(0xFF94A3B8),
        ),
        onPressed: onToggle,
      ),
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
    ),
  );
}

class _DisabledDropdown extends StatelessWidget {
  final String label;

  const _DisabledDropdown(this.label);

  @override
  Widget build(BuildContext context) => Container(
    height: 52.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    alignment: AlignmentDirectional.centerStart,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Text(
      label,
      style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
    ),
  );
}
