import '../../../../../index/index_main.dart';

class AddBranchManagerSheet extends StatefulWidget {
  final OwnerSetupController controller;
  const AddBranchManagerSheet({super.key, required this.controller});

  @override
  State<AddBranchManagerSheet> createState() => _AddBranchManagerSheetState();
}

class _AddBranchManagerSheetState extends State<AddBranchManagerSheet> {
  final _branchCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  static final _phoneRx = RegExp(r'^(010|011|012|015)\d{8}$');

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  @override
  void initState() {
    super.initState();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('setup_add_branch_manager', 3);
  }

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
    final phone = _phoneCtrl.text.trim();
    if (branchName.isEmpty) {
      Loader.showError('setup_owner_branch_name_required'.tr);
      return;
    }
    if (managerName.isEmpty) {
      Loader.showError('setup_manager_name_required'.tr);
      return;
    }
    if (!_phoneRx.hasMatch(phone)) {
      Loader.showError('nursery_error_phone_invalid'.tr);
      return;
    }
    Get.back();
    widget.controller.addBranchWithManager(
      branchName: branchName,
      managerName: managerName,
      phone: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.58,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 8.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'setup_add_branch_title'.tr,
                      style: context.typography.mdBold.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: KeyboardActions(
                config: _keyboardService.buildConfig(context, _keys),
                disableScroll: true,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetField(
                        controller: _branchCtrl,
                        label: 'setup_branch_name_label'.tr,
                        hint: 'setup_branch_name_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[0]),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _SheetField(
                        controller: _managerCtrl,
                        label: 'setup_manager_name_label'.tr,
                        hint: 'setup_manager_name_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[1]),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _SheetField(
                        controller: _phoneCtrl,
                        label: 'setup_manager_phone_label'.tr,
                        hint: 'setup_manager_phone_hint'.tr,
                        keyboardType: TextInputType.phone,
                        focusNode: _keyboardService.getFocusNode(_keys[2]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'setup_manager_password_note'.tr,
                        style: context.typography.xsRegular.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'setup_add_btn'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 16,
                      ),
                    ),
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

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.smMedium.copyWith(
            fontSize: 14,
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          inputFormatters: const [EnglishDigitsFormatter()],
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: textInputAction == TextInputAction.next
              ? (_) => FocusScope.of(context).nextFocus()
              : null,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
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
              borderSide: const BorderSide(
                color: Color(0xFF5E35B1),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
