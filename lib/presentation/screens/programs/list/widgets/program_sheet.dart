import '../../../../../index/index_main.dart';

class ProgramSheet extends StatefulWidget {
  final ProgramModel? initial;
  const ProgramSheet({super.key, this.initial});

  @override
  State<ProgramSheet> createState() => _ProgramSheetState();
}

class _ProgramSheetState extends State<ProgramSheet> {
  late final ProgramParentService _service;
  late final BranchParentService _branchService;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final ageGroupCtrl = TextEditingController();
  bool isActive = true;

  List<BranchModel> branches = [];
  final Set<String> selectedBranchIds = {}; // empty = all branches
  bool isLoadingBranches = true;

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<ProgramParentService>();
    _branchService = Get.find<BranchParentService>();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('program_sheet', 3);
    if (isEdit) {
      nameCtrl.text = widget.initial!.name;
      descriptionCtrl.text = widget.initial!.description ?? '';
      ageGroupCtrl.text = widget.initial!.ageGroup ?? '';
      isActive = widget.initial!.isActive;
      selectedBranchIds.addAll(widget.initial!.branchIds);
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(
      callBack: (list) {
        branches = list.whereType<BranchModel>().toList();
      },
    );
    if (mounted) setState(() => isLoadingBranches = false);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    ageGroupCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('program_error_name'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final program = ProgramModel(
      key: id,
      nurseryId: nurseryId,
      name: name,
      description: descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
      ageGroup: ageGroupCtrl.text.trim().isEmpty ? null : ageGroupCtrl.text.trim(),
      branchIds: selectedBranchIds.toList(),
      isActive: isActive,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: program,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('program_success_updated'.tr);
            Get.back();
          } else {
            Loader.showError('program_error_failed'.tr);
          }
        },
      );
    } else {
      await _service.add(
        item: program,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('program_success_added'.tr);
            Get.back();
          } else {
            Loader.showError('program_error_failed'.tr);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
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
                      isEdit ? 'program_edit_title'.tr : 'program_add_title'.tr,
                      style: context.typography.mdBold.copyWith(
                          fontSize: 17,
                          color: const Color(0xFF1E293B)),
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
                      child: Icon(Icons.close_rounded,
                          size: 18.sp, color: const Color(0xFF64748B)),
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
                      _FieldLabel('program_name_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: nameCtrl,
                        hint: 'program_name_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[0]),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('program_description_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: descriptionCtrl,
                        hint: 'program_description_hint'.tr,
                        maxLines: 3,
                        focusNode: _keyboardService.getFocusNode(_keys[1]),
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('program_age_group_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: ageGroupCtrl,
                        hint: 'program_age_group_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[2]),
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('program_branches_label'.tr),
                      SizedBox(height: 4.h),
                      Text(
                        'program_branches_hint'.tr,
                        style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                      SizedBox(height: 8.h),
                      _BranchMultiSelect(
                        loading: isLoadingBranches,
                        branches: branches,
                        selectedIds: selectedBranchIds,
                        onAllTap: () => setState(selectedBranchIds.clear),
                        onToggle: (id) => setState(() {
                          if (selectedBranchIds.contains(id)) {
                            selectedBranchIds.remove(id);
                          } else {
                            selectedBranchIds.add(id);
                          }
                        }),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isActive ? 'program_active'.tr : 'program_inactive'.tr,
                            style: context.typography.smMedium.copyWith(
                              fontSize: 14, color: const Color(0xFF475569),
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (v) => setState(() => isActive = v),
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('program_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
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

// ── Branch multi-select (empty selection = all branches) ──────────────────────

class _BranchMultiSelect extends StatelessWidget {
  final bool loading;
  final List<BranchModel> branches;
  final Set<String> selectedIds;
  final VoidCallback onAllTap;
  final void Function(String) onToggle;

  const _BranchMultiSelect({
    required this.loading,
    required this.branches,
    required this.selectedIds,
    required this.onAllTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 40.h,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 20.w, height: 20.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final allSelected = selectedIds.isEmpty;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _BranchChip(
          label: 'program_all_branches'.tr,
          selected: allSelected,
          onTap: onAllTap,
        ),
        ...branches.map((b) => _BranchChip(
              label: b.name,
              selected: selectedIds.contains(b.key),
              onTap: () => onToggle(b.key ?? ''),
            )),
      ],
    );
  }
}

class _BranchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BranchChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16.sp,
                color: selected ? AppColors.primary : const Color(0xFF94A3B8),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: context.typography.smMedium.copyWith(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primary : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    maxLines: maxLines,
    textInputAction: textInputAction,
    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
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
