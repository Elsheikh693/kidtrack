import '../../../../../index/index_main.dart';

class ChildSheet extends StatefulWidget {
  final ChildModel? initial;

  final HandleKeyboardService keyboardService;
  final List<String> keys;

  const ChildSheet({
    super.key,
    this.initial,
    required this.keyboardService,
    required this.keys,
  });

  @override
  State<ChildSheet> createState() => _ChildSheetState();
}

class _ChildSheetState extends State<ChildSheet> {
  late final ChildParentService _service;
  late final BranchParentService _branchService;
  late final ClassroomParentService _classroomService;
  late final ProgramParentService _programService;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  List<BranchModel> branches = [];
  List<ClassroomModel> allClassrooms = [];
  List<ClassroomModel> filteredClassrooms = [];
  List<ProgramModel> allPrograms = [];
  List<ProgramModel> filteredPrograms = [];
  BranchModel? selectedBranch;
  ClassroomModel? selectedClassroom;
  ProgramModel? selectedProgram;
  String selectedGender = 'male';
  String selectedStatus = 'active';
  bool isLoadingLookups = true;

  bool get isEdit => widget.initial != null;

  bool get _hasFixedBranch {
    final role = SessionService().userType;
    return role == UserType.receptionist ||
        role == UserType.teacher ||
        role == UserType.nanny;
  }

  static const _genders = ['male', 'female'];
  static const _statuses = ['active', 'inactive', 'withdrawn'];

  @override
  void initState() {
    super.initState();
    _service = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _programService = Get.find<ProgramParentService>();
    if (isEdit) {
      firstNameCtrl.text = widget.initial!.firstName;
      lastNameCtrl.text = widget.initial!.lastName;
      selectedGender = widget.initial!.gender ?? 'male';
      selectedStatus = widget.initial!.status;
    }
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    await _branchService.getAll(
      callBack: (list) {
        branches = list.whereType<BranchModel>().toList();
        if (isEdit) {
          selectedBranch = branches.firstWhereOrNull(
            (b) => b.key == widget.initial!.branchId,
          );
        } else if (_hasFixedBranch) {
          final sessionBranchId = SessionService().branchId;
          if (sessionBranchId != null && sessionBranchId.isNotEmpty) {
            selectedBranch = branches.firstWhereOrNull(
              (b) => b.key == sessionBranchId,
            );
          }
        }
        _filterPrograms();
        _filterClassrooms();
      },
    );
    await _classroomService.getAll(
      callBack: (list) {
        allClassrooms = list.whereType<ClassroomModel>().toList();
        _filterClassrooms();
        if (isEdit && widget.initial!.classroomId != null) {
          selectedClassroom = allClassrooms.firstWhereOrNull(
            (c) => c.key == widget.initial!.classroomId,
          );
        }
      },
    );
    await _programService.getAll(
      callBack: (list) {
        allPrograms = list
            .whereType<ProgramModel>()
            .where((p) => p.isActive)
            .toList();
        _filterPrograms();
        if (isEdit && widget.initial!.programId != null) {
          selectedProgram = allPrograms.firstWhereOrNull(
            (p) => p.key == widget.initial!.programId,
          );
          _filterClassrooms();
        }
      },
    );
    if (mounted) setState(() => isLoadingLookups = false);
  }

  void _filterClassrooms() {
    if (selectedBranch == null) {
      filteredClassrooms = [];
    } else {
      filteredClassrooms = allClassrooms.where((c) {
        final branchOk =
            c.isAllBranches || c.branchIds.contains(selectedBranch!.key);
        final programOk = selectedProgram == null ||
            c.programIds.isEmpty ||
            c.programIds.contains(selectedProgram!.key);
        return branchOk && programOk;
      }).toList();
    }
    if (selectedClassroom != null &&
        !filteredClassrooms.any((c) => c.key == selectedClassroom!.key)) {
      selectedClassroom = null;
    }
  }

  void _filterPrograms() {
    if (selectedBranch == null) {
      filteredPrograms = [];
    } else {
      filteredPrograms = allPrograms
          .where((p) => p.isAllBranches || p.branchIds.contains(selectedBranch!.key))
          .toList();
    }
    selectedProgram = null;
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    if (firstName.isEmpty) {
      Loader.showError('child_error_first_name'.tr);
      return;
    }
    if (lastName.isEmpty) {
      Loader.showError('child_error_last_name'.tr);
      return;
    }
    if (selectedBranch == null) {
      Loader.showError('child_error_branch'.tr);
      return;
    }
    final nurseryId = SessionService().nurseryId ?? '';
    final id = isEdit
        ? (widget.initial!.key ?? const Uuid().v4())
        : const Uuid().v4();
    final child = ChildModel(
      key: id,
      nurseryId: nurseryId,
      branchId: selectedBranch!.key ?? '',
      classroomId: selectedClassroom?.key,
      firstName: firstName,
      lastName: lastName,
      gender: selectedGender,
      status: selectedStatus,
      programId: selectedProgram?.key,
    );
    Loader.show();
    if (isEdit) {
      await _service.update(
        item: child,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('child_success_updated'.tr);
            Get.back();
          } else {
            Loader.showError('child_error_failed'.tr);
          }
        },
      );
    } else {
      await _service.add(
        item: child,
        callBack: (status) {
          Loader.dismiss();
          if (status == ResponseStatus.success) {
            Loader.showSuccess('child_success_added'.tr);
            Get.back();
          } else {
            Loader.showError('child_error_failed'.tr);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────
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
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 8.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? 'child_edit_title'.tr : 'child_add_title'.tr,
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
          // ── Scrollable form ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14.h),

                _FieldLabel('child_first_name_label'.tr),
                SizedBox(height: 6.h),
                _InputField(
                  controller: firstNameCtrl,
                  hint: 'child_first_name_hint'.tr,
                  focusNode: widget.keyboardService.getFocusNode(
                    widget.keys[1],
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(
                    widget.keyboardService.getFocusNode(widget.keys[0]),
                  ),
                ),
                SizedBox(height: 14.h),
                _FieldLabel('child_last_name_label'.tr),
                SizedBox(height: 6.h),
                _InputField(
                  controller: lastNameCtrl,
                  hint: 'child_last_name_hint'.tr,
                  focusNode: widget.keyboardService.getFocusNode(
                    widget.keys[2],
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('child_gender_label'.tr),
                          SizedBox(height: 6.h),
                          _DropdownContainer(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedGender,
                                isExpanded: true,
                                style: context.typography.smRegular.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF1E293B),
                                ),
                                items: _genders
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(
                                          g == 'male'
                                              ? 'child_gender_male'.tr
                                              : 'child_gender_female'.tr,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null)
                                    setState(() => selectedGender = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('child_status_label'.tr),
                          SizedBox(height: 6.h),
                          _DropdownContainer(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStatus,
                                isExpanded: true,
                                style: context.typography.smRegular.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF1E293B),
                                ),
                                items: _statuses
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(_statusLabel(s)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null)
                                    setState(() => selectedStatus = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _FieldLabel('child_branch_label'.tr),
                SizedBox(height: 6.h),
                if (isLoadingLookups)
                  _DisabledDropdown('common_no_branch_selected'.tr)
                else if (_hasFixedBranch && selectedBranch != null)
                  _ReadonlyField(selectedBranch!.name)
                else
                  _DropdownContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BranchModel?>(
                        value: selectedBranch,
                        isExpanded: true,
                        hint: Text(
                          'common_no_branch_selected'.tr,
                          style: context.typography.smRegular.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 14,
                          ),
                        ),
                        style: context.typography.smRegular.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF1E293B),
                        ),
                        items: branches
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b.name),
                              ),
                            )
                            .toList(),
                        onChanged: (b) => setState(() {
                          selectedBranch = b;
                          _filterPrograms();
                          _filterClassrooms();
                        }),
                      ),
                    ),
                  ),
                SizedBox(height: 14.h),
                _FieldLabel('child_program_label'.tr),
                SizedBox(height: 6.h),
                if (isLoadingLookups)
                  _DisabledDropdown('child_program_none'.tr)
                else
                  _ProgramSelector(
                    programs: filteredPrograms,
                    selected: selectedProgram,
                    onChanged: (p) => setState(() {
                      selectedProgram = p;
                      _filterClassrooms();
                    }),
                  ),
                SizedBox(height: 14.h),
                _FieldLabel('child_classroom_label'.tr),
                SizedBox(height: 6.h),
                _DropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ClassroomModel?>(
                      value: selectedClassroom,
                      isExpanded: true,
                      hint: Text(
                        'child_classroom_none'.tr,
                        style: context.typography.smRegular.copyWith(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 14,
                        ),
                      ),
                      style: context.typography.smRegular.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                      items: [
                        DropdownMenuItem<ClassroomModel?>(
                          value: null,
                          child: Text('child_classroom_none'.tr),
                        ),
                        ...filteredClassrooms.map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        ),
                      ],
                      onChanged: (c) => setState(() => selectedClassroom = c),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                ],
              ),
            ),
          ),
          // ── Save button ────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: _SubmitButton(label: 'child_save'.tr, onTap: _submit),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'active':
        return 'child_status_active'.tr;
      case 'withdrawn':
        return 'child_status_withdrawn'.tr;
      default:
        return 'child_status_inactive'.tr;
    }
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

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
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    keyboardType: TextInputType.text,
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

class _ReadonlyField extends StatelessWidget {
  final String text;

  const _ReadonlyField(this.text);

  @override
  Widget build(BuildContext context) => Container(
    height: 52.h,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    alignment: AlignmentDirectional.centerStart,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Text(
      text,
      style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
    ),
  );
}

class _ProgramSelector extends StatelessWidget {
  final List<ProgramModel> programs;
  final ProgramModel? selected;
  final ValueChanged<ProgramModel?> onChanged;

  const _ProgramSelector({
    required this.programs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return const _ReadonlyField('—');
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: programs.map((p) {
        final isSelected = selected?.key == p.key;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18.sp,
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                ),
                SizedBox(width: 7.w),
                Text(
                  p.name,
                  style: context.typography.smSemiBold.copyWith(
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
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
    child: Text(
      label,
      style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: context.typography.smSemiBold.copyWith(fontSize: 16),
      ),
    ),
  );
}
