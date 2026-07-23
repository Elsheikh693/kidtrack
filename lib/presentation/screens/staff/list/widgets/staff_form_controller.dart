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
  // Country for the login phone (identity key). See PhoneUtils for the storage
  // rule that keeps existing Egyptian numbers backward compatible.
  final Rx<PhoneCountry> selectedCountry = PhoneUtils.egypt.obs;
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
    final detected = PhoneUtils.detect(initialStaff!.phone);
    selectedCountry.value = detected.country;
    phoneCtrl.text = detected.local;
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
    final phone = PhoneUtils.normalize(selectedCountry.value, phoneCtrl.text.trim());
    Loader.show();
    await _staffService.update(
      item: initialStaff!.copyWith(
        name: name,
        phone: phone.nullIfEmpty,
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
      callBack: (status) async {
        if (status == ResponseStatus.success) {
          final newRole = selectedTemplate.value.toUserType();
          final nurseryId = initialStaff!.nurseryId;
          final identity = Get.find<IdentityService>();
          // A role change moves the membership key ({nid}_{role}) — drop the
          // stale one before writing the new so we never leave two staff hats.
          if (initialStaff!.role != newRole) {
            await identity.removeMembership(
              uid: initialStaff!.uid,
              nurseryId: nurseryId,
              role: initialStaff!.role.name,
            );
          }
          // Syncs identity + membership so a role change reaches next sign-in.
          await identity.attachMembership(
            uid: initialStaff!.uid,
            role: newRole.name,
            nurseryId: nurseryId,
            branchId: _resolvedBranchId,
            name: name,
            phone: phone,
          );
        }
        Loader.dismiss();
        if (status == ResponseStatus.success) Get.back();
      },
    );
  }

  // ── Create (new staff) ──────────────────────────────────────────────────────

  Future<void> _create(String name) async {
    final rawPhone = phoneCtrl.text.trim();

    if (rawPhone.isEmpty) {
      Loader.showError('staff_form_phone_required'.tr);
      return;
    }
    if (!PhoneUtils.isValid(selectedCountry.value, rawPhone)) {
      Loader.showError('staff_form_phone_invalid'.tr);
      return;
    }
    // Canonical stored form for the picked country — also doubles as the account
    // password (Firebase Auth requires ≥ 6 chars, which every valid number is).
    final phone = PhoneUtils.normalize(selectedCountry.value, rawPhone);

    Loader.show();

    // 1. Resolve the identity for this phone. The account is created only if the
    //    phone is brand-new; if this person already has an account (they're a
    //    guardian here, or staff at another nursery) we reuse the SAME uid and
    //    just attach a new membership below — no more "phone already registered".
    final String firebaseUid;
    try {
      final res = await Get.find<IdentityService>()
          .resolveByPhone(phone: phone, name: name);
      firebaseUid = res.uid;
    } catch (_) {
      Loader.showError('staff_form_create_error'.tr);
      return;
    }

    final nurseryId = _session.nurseryId ?? '';
    final role = selectedTemplate.value.toUserType();

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
        role: role,
        salary: double.tryParse(salaryCtrl.text.trim()),
        hireDate: selectedHireDate.value?.millisecondsSinceEpoch,
        nationalId: nationalIdCtrl.text.trim().nullIfEmpty,
        address: addressCtrl.text.trim().nullIfEmpty,
        emergencyPhone: emergencyPhoneCtrl.text.trim().nullIfEmpty,
      ),
      callBack: (status) async {
        if (status != ResponseStatus.success) {
          Loader.showError('staff_form_create_error'.tr);
          return;
        }

        // 3. Attach the staff membership for this nursery + role and merge the
        //    identity (never clobbers other memberships this person may hold).
        await Get.find<IdentityService>().attachMembership(
          uid: firebaseUid,
          role: role.name,
          nurseryId: nurseryId,
          branchId: _resolvedBranchId,
          name: name,
          phone: phone,
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
