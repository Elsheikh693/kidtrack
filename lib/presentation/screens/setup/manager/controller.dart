import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class ManagerSetupController extends GetxController {
  // Steps: 0=Branch 1=Programs 2=Subjects 3=Classrooms 4=Staff 5=Fees
  final currentStep = 0.obs;
  final isLoading = false.obs;

  final branch     = Rxn<BranchModel>();
  final branchNameCtrl = TextEditingController();

  final programs   = <ProgramModel>[].obs;
  final subjects   = <SubjectModel>[].obs;
  final classrooms = <ClassroomModel>[].obs;
  final staffList  = <StaffModel>[].obs;
  final fees       = <PackageModel>[].obs;

  late BranchParentService   _branchService;
  late ProgramParentService  _programService;
  late SubjectParentService  _subjectService;
  late ClassroomParentService _classroomService;
  late StaffParentService    _staffService;
  late PackageParentService  _packageService;
  late PermissionParentService _permService;
  late SessionService        _session;

  @override
  void onInit() {
    super.onInit();
    _branchService   = Get.find<BranchParentService>();
    _programService  = Get.find<ProgramParentService>();
    _subjectService  = Get.find<SubjectParentService>();
    _classroomService= Get.find<ClassroomParentService>();
    _staffService    = Get.find<StaffParentService>();
    _packageService  = Get.find<PackageParentService>();
    _permService     = Get.find<PermissionParentService>();
    _session         = Get.find<SessionService>();
    _loadAll();
  }

  @override
  void onClose() {
    branchNameCtrl.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  void _loadAll() {
    _loadBranch();
    _loadPrograms();
    _loadSubjects();
    _loadClassrooms();
    _loadStaff();
    _loadFees();
  }

  Future<void> _loadBranch() async {
    final branchId = _session.branchId ?? '';
    if (branchId.isEmpty) return;
    await _branchService.getAll(callBack: (list) {
      BranchModel? match;
      for (final b in list.whereType<BranchModel>()) {
        if (b.key == branchId) {
          match = b;
          break;
        }
      }
      if (match != null) {
        branch.value = match;
        // Pre-fill the field with the existing name (set by the owner),
        // but don't clobber what the manager may already be typing.
        if (branchNameCtrl.text.trim().isEmpty) {
          branchNameCtrl.text = match.name;
        }
      }
    });
  }

  Future<void> _loadPrograms() async {
    await _programService.getAll(callBack: (list) {
      programs.value = list.whereType<ProgramModel>().toList();
    });
  }

  Future<void> _loadSubjects() async {
    await _subjectService.getAll(callBack: (list) {
      subjects.value = list.whereType<SubjectModel>().toList();
    });
  }

  Future<void> _loadClassrooms() async {
    await _classroomService.getAll(callBack: (list) {
      classrooms.value = list.whereType<ClassroomModel>().toList();
    });
  }

  Future<void> _loadStaff() async {
    await _staffService.getAll(callBack: (list) {
      staffList.value = list
          .whereType<StaffModel>()
          .where((s) => s.role != UserType.branchManager && s.role != UserType.owner)
          .toList();
    });
  }

  Future<void> _loadFees() async {
    final branchId = _session.branchId ?? '';
    await _packageService.getAll(callBack: (list) {
      // Packages are branch-specific. Show only the current branch's fees.
      fees.value = list.whereType<PackageModel>().where((p) {
        if (branchId.isEmpty) return true;
        return p.branchId == branchId;
      }).toList();
    });
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void next() {
    switch (currentStep.value) {
      case 0:
        if (branchNameCtrl.text.trim().isEmpty) {
          Loader.showError('setup_branch_name_required'.tr);
          return;
        }
        _saveBranchName(); // saves, then advances on success
        return;
      case 1:
        if (programs.isEmpty) {
          Loader.showError('setup_manager_program_required'.tr);
          return;
        }
        break;
      case 2:
        if (subjects.isEmpty) {
          Loader.showError('setup_manager_subject_required'.tr);
          return;
        }
        break;
      case 3:
        if (classrooms.isEmpty) {
          Loader.showError('setup_manager_classroom_required'.tr);
          return;
        }
        break;
    }
    if (currentStep.value < 5) {
      currentStep.value++;
    } else {
      _completeSetup();
    }
  }

  void back() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ── Branch ────────────────────────────────────────────────────────────────

  Future<void> _saveBranchName() async {
    final name = branchNameCtrl.text.trim();
    final current = branch.value;
    // No branch record yet (shouldn't normally happen) — just move on.
    if (current == null) {
      currentStep.value++;
      return;
    }
    // Unchanged name — skip the network write, just advance.
    if (current.name.trim() == name) {
      currentStep.value++;
      return;
    }
    Loader.show();
    final updated = current.copyWith(name: name);
    await _branchService.update(
      item: updated,
      callBack: (status) {
        if (status == ResponseStatus.success) {
          branch.value = updated;
          Loader.dismiss();
          currentStep.value++;
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  // ── Programs ──────────────────────────────────────────────────────────────

  Future<void> addProgram(String name, {String? description}) async {
    await _programService.add(
      item: ProgramModel(
          key: const Uuid().v4(),
          nurseryId: _session.nurseryId ?? '',
          name: name,
          description: description?.nullIfEmpty),
      callBack: (status) {
        if (status == ResponseStatus.success) {
          _loadPrograms();
          Loader.showSuccess('setup_program_added'.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  Future<void> deleteProgram(String id) async {
    Loader.show();
    await _programService.delete(
        id: id,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            programs.removeWhere((p) => p.key == id);
            Loader.dismiss();
          } else {
            Loader.showError('common_error'.tr);
          }
        });
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  Future<void> addSubject(String name) async {
    await _subjectService.add(
      item: SubjectModel(
        key: const Uuid().v4(),
        nurseryId: _session.nurseryId ?? '',
        programId: '',
        name: name,
      ),
      callBack: (status) {
        if (status == ResponseStatus.success) {
          _loadSubjects();
          Loader.showSuccess('setup_subject_added'.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  Future<void> deleteSubject(String id) async {
    Loader.show();
    await _subjectService.delete(
        id: id,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            subjects.removeWhere((s) => s.key == id);
            Loader.dismiss();
          } else {
            Loader.showError('common_error'.tr);
          }
        });
  }

  // ── Classrooms ────────────────────────────────────────────────────────────

  Future<void> addClassroom(String name, {int? capacity}) async {
    await _classroomService.add(
      item: ClassroomModel(
        key: const Uuid().v4(),
        nurseryId: _session.nurseryId ?? '',
        // Empty branchIds = available in all branches by default.
        name: name,
        capacity: capacity,
      ),
      callBack: (status) {
        if (status == ResponseStatus.success) {
          _loadClassrooms();
          Loader.showSuccess('setup_classroom_added'.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  Future<void> deleteClassroom(String id) async {
    Loader.show();
    await _classroomService.delete(
        id: id,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            classrooms.removeWhere((c) => c.key == id);
            Loader.dismiss();
          } else {
            Loader.showError('common_error'.tr);
          }
        });
  }

  // ── Staff ─────────────────────────────────────────────────────────────────

  Future<void> addStaff({
    required String name,
    required String phone,
    required String password,
    required StaffTemplate template,
    String? classroomId,
    List<String> subjectIds = const [],
  }) async {
    Loader.show();
    final nurseryId = _session.nurseryId ?? '';
    final branchId  = _session.branchId  ?? '';
    final email = '$phone@gmail.com';
    String uid;
    try {
      uid = await _createFirebaseAuth(email, password);
    } catch (e) {
      Loader.showError(e.toString());
      return;
    }
    await _staffService.add(
      item: StaffModel(
        uid: uid,
        nurseryId: nurseryId,
        branchId: branchId,
        classroomId: classroomId,
        subjectIds: subjectIds,
        name: name,
        phone: phone.nullIfEmpty,
        role: template.toUserType(),
        template: template,
      ),
      callBack: (status) async {
        if (status != ResponseStatus.success) {
          Loader.showError('setup_staff_error'.tr);
          return;
        }
        await FirebaseDatabase.instance.ref('users/$uid').set({
          'uid': uid,
          'name': name,
          'phone': phone,
          'nurseryId': nurseryId,
          'branchId': branchId,
          'userType': template.toUserType().name,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        await _permService.add(
          item: PermissionSetModel(
            employeeId: uid,
            permissions: PermissionTemplates.forTemplate(template),
          ),
          callBack: (_) {
            _loadStaff();
            Loader.showSuccess('setup_staff_added'.tr);
          },
        );
      },
    );
  }

  Future<String> _createFirebaseAuth(String email, String password) async {
    final appName = 'mgr_setup_${DateTime.now().millisecondsSinceEpoch}';
    final secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await auth.signOut();
      return cred.user!.uid;
    } finally {
      await secondaryApp.delete();
    }
  }

  // ── Fees ──────────────────────────────────────────────────────────────────

  Future<void> addFee({
    required String name,
    required double price,
    required String duration,
    String? description,
  }) async {
    await _packageService.add(
      item: PackageModel(
        key: const Uuid().v4(),
        nurseryId: _session.nurseryId ?? '',
        // Packages belong to a specific branch — stamp the current one.
        branchId: _session.branchId,
        name: name,
        price: price,
        duration: duration,
        description: description?.nullIfEmpty,
      ),
      callBack: (status) {
        if (status == ResponseStatus.success) {
          _loadFees();
          Loader.showSuccess('setup_fee_added'.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  Future<void> deleteFee(String id) async {
    Loader.show();
    await _packageService.delete(
        id: id,
        callBack: (status) {
          if (status == ResponseStatus.success) {
            fees.removeWhere((f) => f.key == id);
            Loader.dismiss();
          } else {
            Loader.showError('common_error'.tr);
          }
        });
  }

  // ── Complete ──────────────────────────────────────────────────────────────

  Future<void> _completeSetup() async {
    Loader.show();
    try {
      final uid = _session.userId ?? '';
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({'setupDone': true});
      await SetupLocalCheck.markDone(uid);
      Loader.dismiss();
      Get.offAllNamed(mainView);
    } catch (_) {
      Loader.showError('common_error'.tr);
    }
  }
}

extension _StaffTemplateX on StaffTemplate {
  UserType toUserType() {
    switch (this) {
      case StaffTemplate.owner:         return UserType.owner;
      case StaffTemplate.branchManager: return UserType.branchManager;
      case StaffTemplate.receptionist:  return UserType.receptionist;
      case StaffTemplate.teacher:       return UserType.teacher;
      case StaffTemplate.nanny:         return UserType.nanny;
      case StaffTemplate.busChaperone:  return UserType.busChaperone;
    }
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
