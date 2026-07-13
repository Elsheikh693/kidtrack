import 'package:firebase_database/firebase_database.dart';
import '../../../../../index/index_main.dart';

class StaffFormController extends GetxController {
  final StaffModel? initialStaff;

  StaffFormController({this.initialStaff});

  late StaffParentService _staffService;
  late BranchParentService _branchService;
  late PermissionParentService _permService;
  late ShiftParentService _shiftService;
  late SessionService _session;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();
  final nationalIdCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();

  final Rxn<DateTime> selectedHireDate = Rxn();

  final Rx<StaffTemplate> selectedTemplate = StaffTemplate.teacher.obs;
  final Rx<BranchModel?> selectedBranch = Rx(null);
  final RxList<ShiftModel> shifts = <ShiftModel>[].obs;
  final RxList<String> selectedShiftIds = <String>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxBool isEdit = false.obs;

  // Resolves before the first branch fetch completes, so submit() can wait.
  late Future<void> _branchesReady;

  @override
  void onInit() {
    super.onInit();
    _staffService = Get.find<StaffParentService>();
    _branchService = Get.find<BranchParentService>();
    _permService = Get.find<PermissionParentService>();
    _shiftService = Get.find<ShiftParentService>();
    _session = Get.find<SessionService>();
    _branchesReady = _loadBranches();
    _loadShifts();
    _prefill();
  }

  Future<void> _loadShifts() async {
    shifts.value = await _shiftService.getActive();
  }

  bool isShiftSelected(String id) => selectedShiftIds.contains(id);

  void toggleShift(String id) {
    if (selectedShiftIds.contains(id)) {
      selectedShiftIds.remove(id);
    } else {
      selectedShiftIds.add(id);
    }
  }

  /// The branch to persist: the user's pick, or — when the nursery has a single
  /// branch — that branch automatically, so the staff member is never orphaned.
  String? get _resolvedBranchId =>
      (selectedBranch.value ??
              (branches.length == 1 ? branches.first : null))
          ?.key;

  void _prefill() {
    if (initialStaff == null) return;
    isEdit.value = true;
    nameCtrl.text = initialStaff!.name;
    phoneCtrl.text = initialStaff!.phone ?? '';
    selectedTemplate.value = initialStaff!.template;
    selectedShiftIds.assignAll(initialStaff!.shiftIds);
    if (initialStaff!.salary != null) {
      salaryCtrl.text = initialStaff!.salary!.toStringAsFixed(0);
    }
    if (initialStaff!.hireDate != null) {
      selectedHireDate.value =
          DateTime.fromMillisecondsSinceEpoch(initialStaff!.hireDate!);
    }
    nationalIdCtrl.text = initialStaff!.nationalId ?? '';
    addressCtrl.text = initialStaff!.address ?? '';
    emergencyPhoneCtrl.text = initialStaff!.emergencyPhone ?? '';
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(
      callBack: (list) {
        branches.value = list.whereType<BranchModel>().toList();
        if (initialStaff?.branchId != null) {
          selectedBranch.value = branches.firstWhereOrNull(
            (b) => b.key == initialStaff!.branchId,
          );
        } else if (branches.length == 1) {
          // Only one branch — no point making the user pick it.
          selectedBranch.value = branches.first;
        }
      },
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('staff_form_name_required'.tr);
      return;
    }
    // Make sure branches are loaded so single-branch auto-assignment applies
    // even if the user submits before the fetch finishes.
    await _branchesReady;
    if (isEdit.value && initialStaff != null) {
      await _update(name);
    } else {
      await _create(name);
    }
  }

  // ── Update (edit) ───────────────────────────────────────────────────────────

  Future<void> _update(String name) async {
    Loader.show();
    await _staffService.update(
      item: initialStaff!.copyWith(
        name: name,
        phone: phoneCtrl.text.trim().nullIfEmpty,
        template: selectedTemplate.value,
        role: selectedTemplate.value.toUserType(),
        branchId: _resolvedBranchId,
        shiftIds: selectedShiftIds.toList(),
        salary: double.tryParse(salaryCtrl.text.trim()),
        hireDate: selectedHireDate.value?.millisecondsSinceEpoch,
        nationalId: nationalIdCtrl.text.trim().nullIfEmpty,
        address: addressCtrl.text.trim().nullIfEmpty,
        emergencyPhone: emergencyPhoneCtrl.text.trim().nullIfEmpty,
      ),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) Get.back();
      },
    );
  }

  // ── Create (new staff) ──────────────────────────────────────────────────────

  Future<void> _create(String name) async {
    final phone = phoneCtrl.text.trim();

    if (phone.isEmpty) {
      Loader.showError('staff_form_phone_required'.tr);
      return;
    }
    // The phone number doubles as the staff member's password. Firebase Auth
    // requires a minimum of 6 characters.
    if (phone.length < 6) {
      Loader.showError('staff_form_phone_short'.tr);
      return;
    }

    Loader.show();

    // 1. Create Firebase Auth account without signing out the current owner
    final email = '$phone@gmail.com';
    String firebaseUid;
    try {
      firebaseUid = await _createFirebaseAuth(email, phone);
    } catch (e) {
      Loader.showError(e.toString());
      return;
    }

    final nurseryId = _session.nurseryId ?? '';

    // 2. Add staff record to platform/$nurseryId/staff/
    await _staffService.add(
      item: StaffModel(
        uid: firebaseUid,
        nurseryId: nurseryId,
        branchId: _resolvedBranchId,
        shiftIds: selectedShiftIds.toList(),
        name: name,
        phone: phone.nullIfEmpty,
        template: selectedTemplate.value,
        role: selectedTemplate.value.toUserType(),
        salary: double.tryParse(salaryCtrl.text.trim()),
        hireDate: selectedHireDate.value?.millisecondsSinceEpoch,
        nationalId: nationalIdCtrl.text.trim().nullIfEmpty,
        address: addressCtrl.text.trim().nullIfEmpty,
        emergencyPhone: emergencyPhoneCtrl.text.trim().nullIfEmpty,
      ),
      callBack: (status) async {
        if (status != ResponseStatus.success) {
          await _rollbackFirebaseAuth(firebaseUid);
          Loader.showError('staff_form_create_error'.tr);
          return;
        }

        // 3. Write users/$uid so login can resolve nurseryId + userType
        await _writeUsersNode(
          uid: firebaseUid,
          name: name,
          phone: phone,
          nurseryId: nurseryId,
          role: selectedTemplate.value.toUserType(),
        );

        // 4. Add permissions
        await _permService.add(
          item: PermissionSetModel(
            employeeId: firebaseUid,
            permissions: PermissionTemplates.forTemplate(
              selectedTemplate.value,
            ),
          ),
          callBack: (_) {
            Loader.dismiss();
            Get.back();
          },
        );
      },
    );
  }

  // ── Firebase Auth (secondary app) ──────────────────────────────────────────

  Future<String> _createFirebaseAuth(String email, String password) async {
    // Use a secondary Firebase app so the owner's session is not affected
    final appName = 'staff_temp_${DateTime.now().millisecondsSinceEpoch}';
    final secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await auth.signOut();
      return cred.user!.uid;
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> _rollbackFirebaseAuth(String uid) async {
    // Client SDK cannot delete other users — best handled by Cloud Functions.
    // Left as no-op; orphan auth accounts should be cleaned server-side.
  }

  // ── Realtime Database ──────────────────────────────────────────────────────

  Future<void> _writeUsersNode({
    required String uid,
    required String name,
    required String phone,
    required String nurseryId,
    required UserType role,
  }) async {
    await FirebaseDatabase.instance.ref('users/$uid').set({
      'uid': uid,
      'name': name,
      'phone': phone,
      'nurseryId': nurseryId,
      'userType': role.name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    salaryCtrl.dispose();
    nationalIdCtrl.dispose();
    addressCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    super.onClose();
  }
}

extension on StaffTemplate {
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
