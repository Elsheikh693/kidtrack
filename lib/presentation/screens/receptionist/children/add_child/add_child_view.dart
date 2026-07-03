import '../../../../../index/index_main.dart';
import 'widgets/add_child_fields.dart';
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
  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  final nameCtrl = TextEditingController();

  List<BranchModel> branches = [];
  List<ClassroomModel> allClassrooms = [];
  List<ClassroomModel> filteredClassrooms = [];
  List<ProgramModel> allPrograms = [];
  List<ProgramModel> filteredPrograms = [];
  List<PackageModel> packages = [];
  BranchModel? selectedBranch;
  ClassroomModel? selectedClassroom;
  ProgramModel? selectedProgram;
  PackageModel? selectedPackage;
  String selectedGender = 'male';
  String? selectedShift;
  bool isLoadingLookups = true;

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
      packageId: selectedPackage?.key,
    );
    Loader.show();
    await _service.add(
      item: child,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('child_success_added'.tr);
          Get.offNamed(
            parentAccountView,
            arguments: {'childId': id, 'childName': child.fullName},
          );
        } else {
          Loader.showError('child_error_failed'.tr);
        }
      },
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
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
              ShiftSelector(
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
              SizedBox(height: 18.h),
              FieldLabel('child_branch_label'.tr),
              SizedBox(height: 8.h),
              if (isLoadingLookups)
                const ReadonlyField('...')
              else if (_hasFixedBranch && selectedBranch != null)
                LockedField(selectedBranch!.name)
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
              FieldLabel('child_package_label'.tr),
              SizedBox(height: 8.h),
              if (isLoadingLookups)
                const ReadonlyField('...')
              else
                AddChildPackageDropdown(
                  packages: packages,
                  selected: selectedPackage,
                  onChanged: (p) => setState(() => selectedPackage = p),
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
