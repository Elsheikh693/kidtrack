import '../../../../../index/index_main.dart';
import 'widgets/add_child_fields.dart';
import 'widgets/guardian_entry.dart';
import 'widgets/guardian_phone_section.dart';
import 'widgets/shift_selector.dart';

class AddChildView extends StatefulWidget {
  const AddChildView({super.key});

  @override
  State<AddChildView> createState() => _AddChildViewState();
}

class _AddChildViewState extends State<AddChildView> {
  late final ChildParentService _service;
  late final BranchParentService _branchService;
  late final ClassroomParentService _classroomService;
  late final ProgramParentService _programService;
  late final PackageParentService _packageService;
  late final ParentAccountService _parentAccountService;
  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  final nameCtrl = TextEditingController();

  List<BranchModel> branches = [];
  List<ClassroomModel> allClassrooms = [];
  List<ClassroomModel> filteredClassrooms = [];
  List<ProgramModel> allPrograms = [];
  List<ProgramModel> filteredPrograms = [];
  List<PackageModel> packages = [];
  List<ShiftModel> shifts = [];
  List<ParentModel> allParents = [];
  BranchModel? selectedBranch;
  ClassroomModel? selectedClassroom;
  ProgramModel? selectedProgram;
  final List<PackageModel> selectedPackages = [];
  String selectedGender = 'male';
  String? selectedShift;
  bool isLoadingLookups = true;

  // ── Guardians (father + mother by default, plus any extras) ──────────────
  final List<GuardianEntry> guardians = [
    GuardianEntry(relationship: 'father', fixedRelationship: true),
    GuardianEntry(relationship: 'mother', fixedRelationship: true),
  ];

  // uids already picked in other slots — excluded from a slot's search results.
  Set<String> _excludedUids(int slotIndex) {
    final ids = <String>{};
    for (var i = 0; i < guardians.length; i++) {
      if (i == slotIndex) continue;
      final uid = guardians[i].selected?.uid;
      if (uid != null) ids.add(uid);
    }
    return ids;
  }

  String _guardianHeader(GuardianEntry g) {
    if (!g.fixedRelationship) return 'child_guardian_other'.tr;
    return g.relationship == 'father'
        ? 'guardian_create_relationship_father'.tr
        : 'guardian_create_relationship_mother'.tr;
  }

  bool get _hasFixedBranch {
    final role = SessionService().userType;
    return role == UserType.receptionist ||
        role == UserType.teacher ||
        role == UserType.nanny;
  }

  @override
  void initState() {
    super.initState();
    _service = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _programService = Get.find<ProgramParentService>();
    _packageService = Get.find<PackageParentService>();
    _parentAccountService = Get.find<ParentAccountService>();
    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('rc_add_child', 1);
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    await _branchService.getAll(
      callBack: (list) {
        branches = list.whereType<BranchModel>().toList();
        if (_hasFixedBranch) {
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
      },
    );
    await _programService.getAll(
      callBack: (list) {
        allPrograms = list
            .whereType<ProgramModel>()
            .where((p) => p.isActive)
            .toList();
        _filterPrograms();
      },
    );
    await _packageService.getAll(
      callBack: (list) {
        packages = list
            .whereType<PackageModel>()
            .where((p) => p.isActive)
            .toList();
      },
    );
    await Get.find<GuardianParentService>().getAll(
      callBack: (list) => allParents = list.whereType<ParentModel>().toList(),
    );
    shifts = await Get.find<ShiftParentService>().getActive();
    // Only one shift? Pre-select it — no point making the user pick.
    if (shifts.length == 1) selectedShift = shifts.first.key;
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

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('child_error_name'.tr);
      return;
    }
    final parts = name.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    if (selectedShift == null) {
      Loader.showError('child_error_shift'.tr);
      return;
    }
    if (selectedBranch == null) {
      Loader.showError('child_error_branch'.tr);
      return;
    }

    // At least one guardian is required; every filled slot must be valid (an
    // existing guardian picked, or a valid new number + name).
    final filledGuardians = guardians.where((g) => g.hasInput).toList();
    if (filledGuardians.isEmpty) {
      Loader.showError('child_error_guardian_required'.tr);
      return;
    }
    for (final g in filledGuardians) {
      if (g.selected != null) continue;
      if (!PhoneUtils.isValid(g.country, g.phoneCtrl.text.trim())) {
        Loader.showError('child_error_guardian_phone'.tr);
        return;
      }
      if (g.nameCtrl.text.trim().isEmpty) {
        Loader.showError('guardian_create_error_name'.tr);
        return;
      }
    }

    final id = const Uuid().v4();
    final child = ChildModel(
      key: id,
      nurseryId: SessionService().nurseryId ?? '',
      branchId: selectedBranch!.key ?? '',
      classroomId: selectedClassroom?.key,
      firstName: firstName,
      lastName: lastName,
      gender: selectedGender,
      status: 'active',
      shift: selectedShift,
      programId: selectedProgram?.key,
      packageIds:
          selectedPackages.map((p) => p.key).whereType<String>().toList(),
    );

    Loader.show();
    final childDone = Completer<ResponseStatus>();
    await _service.add(item: child, callBack: childDone.complete);
    if (await childDone.future != ResponseStatus.success) {
      Loader.dismiss();
      Loader.showError('child_error_failed'.tr);
      return;
    }

    // Link (or create) each guardian — reuses the identity-aware account service
    // so a phone that already belongs to someone is not duplicated. The first
    // guardian with no existing primary becomes the child's primary guardian.
    var allGuardiansOk = true;
    for (final g in filledGuardians) {
      final bool ok;
      if (g.selected != null) {
        ok = await _parentAccountService.linkChildToExistingParent(
          parentId: g.selected!.uid,
          childId: id,
          relationship: g.relationship,
          onError: Loader.showError,
        );
      } else {
        final phone = PhoneUtils.normalize(g.country, g.phoneCtrl.text.trim());
        ok = await _parentAccountService.createAccount(
          name: g.nameCtrl.text.trim(),
          phone: phone,
          password: phone,
          childIds: [id],
          relationship: g.relationship,
          onError: Loader.showError,
        );
      }
      if (!ok) allGuardiansOk = false;
    }

    if (allGuardiansOk) Loader.showSuccess('child_success_added'.tr);
    // On failure the service already surfaced the error; the child is saved and
    // any guardian can still be linked later from the child profile.
    Get.back();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    for (final g in guardians) {
      g.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'child_add_title'.tr,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20.sp, color: const Color(0xFF374151)),
          onPressed: () => Get.back(),
        ),
      ),
      body: KeyboardActions(
        config: _keyboardService.buildConfig(context, _keys),
        disableScroll: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddChildNameField(
                nameCtrl: nameCtrl,
                focus: _keyboardService.getFocusNode(_keys[0]),
              ),
              SizedBox(height: 18.h),
              FieldLabel('child_shift_label'.tr),
              SizedBox(height: 8.h),
              if (isLoadingLookups)
                const ReadonlyField('...')
              else
                ShiftSelector(
                  shifts: shifts,
                  value: selectedShift,
                  onChanged: (s) => setState(() => selectedShift = s),
                ),
              SizedBox(height: 18.h),
              FieldLabel('child_gender_label'.tr),
              SizedBox(height: 8.h),
              AddChildGenderDropdown(
                value: selectedGender,
                onChanged: (v) => setState(() => selectedGender = v),
              ),
              // Branch is fixed from the session for receptionist/teacher/nanny
              // (set silently in _loadLookups); only branch-choosing roles see it.
              if (!_hasFixedBranch) ...[
                SizedBox(height: 18.h),
                FieldLabel('child_branch_label'.tr),
                SizedBox(height: 8.h),
                if (isLoadingLookups)
                  const ReadonlyField('...')
                else
                  AddChildBranchDropdown(
                    branches: branches,
                    selected: selectedBranch,
                    onChanged: (b) => setState(() {
                      selectedBranch = b;
                      _filterPrograms();
                      _filterClassrooms();
                    }),
                  ),
              ],
              SizedBox(height: 18.h),
              FieldLabel('child_program_label'.tr),
              SizedBox(height: 8.h),
              if (isLoadingLookups)
                const ReadonlyField('...')
              else
                AddChildProgramSelector(
                  programs: filteredPrograms,
                  selected: selectedProgram,
                  onChanged: (p) => setState(() {
                    selectedProgram = p;
                    _filterClassrooms();
                  }),
                ),
              SizedBox(height: 18.h),
              FieldLabel('child_classroom_label'.tr),
              SizedBox(height: 8.h),
              AddChildClassroomDropdown(
                classrooms: filteredClassrooms,
                selected: selectedClassroom,
                onChanged: (c) => setState(() => selectedClassroom = c),
              ),
              SizedBox(height: 18.h),
              FieldLabel('rc_parent_guardians_label'.tr),
              SizedBox(height: 10.h),
              ...guardians.asMap().entries.map((e) {
                final i = e.key;
                final g = e.value;
                return GuardianSlot(
                  entry: g,
                  headerLabel: _guardianHeader(g),
                  allParents: allParents,
                  excludedUids: _excludedUids(i),
                  onChanged: () => setState(() {}),
                  onRemove: g.fixedRelationship
                      ? null
                      : () => setState(() {
                            g.dispose();
                            guardians.remove(g);
                          }),
                );
              }),
              AddGuardianButton(
                onTap: () => setState(
                  () => guardians.add(GuardianEntry(relationship: 'other')),
                ),
              ),
              SizedBox(height: 18.h),
              FieldLabel('child_package_label'.tr),
              SizedBox(height: 8.h),
              if (isLoadingLookups)
                const ReadonlyField('...')
              else
                AddChildPackageSelector(
                  packages: packages,
                  selected: selectedPackages,
                  onToggle: (p) => setState(() {
                    final i =
                        selectedPackages.indexWhere((s) => s.key == p.key);
                    if (i >= 0) {
                      selectedPackages.removeAt(i);
                    } else {
                      selectedPackages.add(p);
                    }
                  }),
                ),
              SizedBox(height: 32.h),
              SubmitButton(label: 'child_register'.tr, onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
