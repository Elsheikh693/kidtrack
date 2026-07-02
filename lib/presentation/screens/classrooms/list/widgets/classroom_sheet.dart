import '../../../../../index/index_main.dart';

class ClassroomSheet extends StatefulWidget {
  final ClassroomModel? initial;
  const ClassroomSheet({super.key, this.initial});

  @override
  State<ClassroomSheet> createState() => _ClassroomSheetState();
}

class _ClassroomSheetState extends State<ClassroomSheet> {
  late final ClassroomParentService _service;
  late final BranchParentService _branchService;
  late final StaffParentService _staffService;
  late final ProgramParentService _programService;

  final nameCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();

  List<BranchModel> branches = [];
  List<StaffModel> teachers = [];
  List<ProgramModel> programs = [];
  final Set<String> selectedBranchIds = {}; // empty = all branches
  StaffModel? selectedTeacher;
  ProgramModel? selectedProgram;
  String selectedShift = 'morning'; // morning / evening / both
  bool isLoadingLookups = true;

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  bool get isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<ClassroomParentService>();
    _branchService = Get.find<BranchParentService>();
    _staffService = Get.find<StaffParentService>();
    _programService = Get.find<ProgramParentService>();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('classroom_sheet', 2);
    if (isEdit) {
      nameCtrl.text = widget.initial!.name;
      capacityCtrl.text = widget.initial!.capacity?.toString() ?? '';
      selectedShift = widget.initial!.shift ?? 'morning';
      selectedBranchIds.addAll(widget.initial!.branchIds);
    }
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    await _branchService.getAll(
      callBack: (list) {
        branches = list.whereType<BranchModel>().toList();
      },
    );
    await _staffService.getAll(
      callBack: (list) {
        teachers = list.whereType<StaffModel>().toList();
        if (isEdit && widget.initial!.teacherId != null) {
          selectedTeacher = teachers.firstWhereOrNull((s) => s.key == widget.initial!.teacherId);
        }
      },
    );
    await _programService.getAll(
      callBack: (list) {
        programs = list
            .whereType<ProgramModel>()
            .where((p) => p.isActive)
            .toList();
        if (isEdit && widget.initial!.programId != null) {
          selectedProgram = programs.firstWhereOrNull((p) => p.key == widget.initial!.programId);
        }
      },
    );
    if (mounted) setState(() => isLoadingLookups = false);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('classroom_error_name_required'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit ? (widget.initial!.key ?? const Uuid().v4()) : const Uuid().v4();
    final classroom = ClassroomModel(
      key: id,
      nurseryId: nurseryId,
      branchIds: selectedBranchIds.toList(),
      programId: selectedProgram?.key,
      name: name,
      shift: selectedShift,
      teacherId: selectedTeacher?.key,
      capacity: int.tryParse(capacityCtrl.text.trim()),
      isActive: widget.initial?.isActive ?? true,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: classroom,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('classroom_success_updated'.tr);
            Get.back();
          } else {
            Loader.showError('classroom_error_failed'.tr);
          }
        },
      );
    } else {
      await _service.add(
        item: classroom,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('classroom_success_added'.tr);
            Get.back();
          } else {
            Loader.showError('classroom_error_failed'.tr);
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
                      isEdit ? 'classroom_edit_title'.tr : 'classroom_add_title'.tr,
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
                      _FieldLabel('classroom_name_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: nameCtrl,
                        hint: 'classroom_name_hint'.tr,
                        focusNode: _keyboardService.getFocusNode(_keys[0]),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('classroom_branches_label'.tr),
                      SizedBox(height: 4.h),
                      Text(
                        'classroom_branches_hint'.tr,
                        style: context.typography.smRegular.copyWith(
                          fontSize: 12, color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _BranchMultiSelect(
                        loading: isLoadingLookups,
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
                      _FieldLabel('classroom_program_label'.tr),
                      SizedBox(height: 6.h),
                      if (isLoadingLookups)
                        _DisabledDropdown('classroom_program_none'.tr)
                      else
                        _ProgramDropdown(
                          programs: programs,
                          selected: selectedProgram,
                          onChanged: (p) => setState(() => selectedProgram = p),
                        ),
                      SizedBox(height: 16.h),
                      _FieldLabel('classroom_form_shift_label'.tr),
                      SizedBox(height: 6.h),
                      _ShiftDropdown(
                        selected: selectedShift,
                        onChanged: (s) => setState(() => selectedShift = s),
                      ),
                      SizedBox(height: 16.h),
                      _FieldLabel('classroom_teacher_label'.tr),
                      SizedBox(height: 6.h),
                      if (isLoadingLookups)
                        _DisabledDropdown('classroom_teacher_none'.tr)
                      else
                        _TeacherDropdown(
                          teachers: teachers,
                          selected: selectedTeacher,
                          onChanged: (t) => setState(() => selectedTeacher = t),
                        ),
                      SizedBox(height: 16.h),
                      _FieldLabel('classroom_capacity_label'.tr),
                      SizedBox(height: 6.h),
                      _InputField(
                        controller: capacityCtrl,
                        hint: 'classroom_capacity_hint'.tr,
                        keyboardType: TextInputType.number,
                        focusNode: _keyboardService.getFocusNode(_keys[1]),
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
                    child: Text('classroom_save'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
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
          label: 'classroom_all_branches'.tr,
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

class _TeacherDropdown extends StatelessWidget {
  final List<StaffModel> teachers;
  final StaffModel? selected;
  final ValueChanged<StaffModel?> onChanged;
  const _TeacherDropdown({
    required this.teachers,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _DropdownContainer(
    child: DropdownButtonHideUnderline(
      child: DropdownButton<StaffModel?>(
        value: selected,
        isExpanded: true,
        hint: Text('classroom_teacher_none'.tr,
            style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        items: [
          DropdownMenuItem<StaffModel?>(
            value: null,
            child: Text('classroom_teacher_none'.tr),
          ),
          ...teachers.map((t) => DropdownMenuItem(
            value: t,
            child: Text(t.name),
          )),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}

class _ProgramDropdown extends StatelessWidget {
  final List<ProgramModel> programs;
  final ProgramModel? selected;
  final ValueChanged<ProgramModel?> onChanged;
  const _ProgramDropdown({
    required this.programs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _DropdownContainer(
    child: DropdownButtonHideUnderline(
      child: DropdownButton<ProgramModel?>(
        value: selected,
        isExpanded: true,
        hint: Text('classroom_program_none'.tr,
            style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        items: [
          DropdownMenuItem<ProgramModel?>(
            value: null,
            child: Text('classroom_program_none'.tr),
          ),
          ...programs.map((p) => DropdownMenuItem(
            value: p,
            child: Text(p.name),
          )),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}

class _ShiftDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ShiftDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => _DropdownContainer(
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        isExpanded: true,
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        items: const ['morning', 'evening', 'both']
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('shift_$s'.tr),
                ))
            .toList(),
        onChanged: (s) {
          if (s != null) onChanged(s);
        },
      ),
    ),
  );
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: child,
  );
}

class _DisabledDropdown extends StatelessWidget {
  final String label;
  const _DisabledDropdown(this.label);

  @override
  Widget build(BuildContext context) => Container(
    height: 52.h,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    alignment: AlignmentDirectional.centerStart,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Text(label, style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
  );
}

// ── Shared helpers (duplicated per file as per CLAUDE.md) ────────────────────

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
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
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
