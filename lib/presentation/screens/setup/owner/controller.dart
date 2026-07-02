import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class OwnerSetupController extends GetxController {
  final isLoading = false.obs;

  // ── Lists ─────────────────────────────────────────────────────────────────
  final branches = <BranchModel>[].obs;
  final managers = <StaffModel>[].obs;

  late BranchParentService _branchService;
  late StaffParentService _staffService;
  late PermissionParentService _permService;
  late SessionService _session;

  @override
  void onInit() {
    super.onInit();
    _branchService  = Get.find<BranchParentService>();
    _staffService   = Get.find<StaffParentService>();
    _permService    = Get.find<PermissionParentService>();
    _session        = Get.find<SessionService>();
    _loadBranches();
    _loadManagers();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadBranches() async {
    await _branchService.getAll(callBack: (list) {
      branches.value = list.whereType<BranchModel>().toList();
    });
  }

  Future<void> _loadManagers() async {
    await _staffService.getAll(callBack: (list) {
      managers.value = list
          .whereType<StaffModel>()
          .where((s) => s.role == UserType.branchManager)
          .toList();
    });
  }

  /// Manager assigned to a given branch (one manager per branch in setup).
  StaffModel? managerForBranch(String? branchId) =>
      managers.firstWhereOrNull((m) => m.branchId == branchId);

  // ── Add branch + its manager together ──────────────────────────────────────

  Future<void> addBranchWithManager({
    required String branchName,
    required String managerName,
    required String phone,
  }) async {
    Loader.show();
    final nurseryId = _session.nurseryId ?? '';
    final makeMain = branches.isEmpty;
    final branchId = const Uuid().v4();
    final email = '$phone@gmail.com';

    // 1) Create the manager auth account first (password = phone).
    String uid;
    try {
      uid = await _createFirebaseAuth(email, phone);
    } catch (_) {
      Loader.showError('setup_owner_manager_error'.tr);
      return;
    }

    // 2) Create the branch.
    if (makeMain) await _clearMainFlag();
    bool branchOk = false;
    await _branchService.add(
      item: BranchModel(
        key: branchId,
        nurseryId: nurseryId,
        name: branchName,
        isMain: makeMain,
      ),
      callBack: (status) => branchOk = status == ResponseStatus.success,
    );
    if (!branchOk) {
      Loader.showError('setup_owner_branch_error'.tr);
      return;
    }

    // 3) Create the manager staff record + user node + permissions.
    await _staffService.add(
      item: StaffModel(
        uid: uid,
        nurseryId: nurseryId,
        branchId: branchId,
        name: managerName,
        phone: phone.nullIfEmpty,
        role: UserType.branchManager,
        template: StaffTemplate.branchManager,
      ),
      callBack: (status) async {
        if (status != ResponseStatus.success) {
          Loader.showError('setup_owner_manager_error'.tr);
          return;
        }
        await FirebaseDatabase.instance.ref('users/$uid').set({
          'uid': uid,
          'name': managerName,
          'phone': phone,
          'nurseryId': nurseryId,
          'branchId': branchId,
          'userType': UserType.branchManager.name,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        await _permService.add(
          item: PermissionSetModel(
            employeeId: uid,
            permissions:
                PermissionTemplates.forTemplate(StaffTemplate.branchManager),
          ),
          callBack: (_) {
            _loadBranches();
            _loadManagers();
            Loader.showSuccess('setup_owner_branch_added'.tr);
          },
        );
      },
    );
  }

  Future<void> setMainBranch(String branchId) async {
    final target = branches.firstWhereOrNull((b) => b.key == branchId);
    if (target == null || target.isMain) return;
    Loader.show();
    await _clearMainFlag();
    await _branchService.update(
      item: target.copyWith(isMain: true),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          _loadBranches();
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  Future<void> _clearMainFlag() async {
    final mains = branches.where((b) => b.isMain).toList();
    for (final b in mains) {
      await _branchService.update(
        item: b.copyWith(isMain: false),
        callBack: (_) {},
      );
    }
  }

  /// Deletes a branch together with its manager (staff doc, user node, perms).
  Future<void> deleteBranch(String id) async {
    Loader.show();
    final manager = managerForBranch(id);
    await _branchService.delete(
      id: id,
      callBack: (status) async {
        if (status != ResponseStatus.success) {
          Loader.showError('common_error'.tr);
          return;
        }
        branches.removeWhere((b) => b.key == id);
        if (manager != null) {
          await _staffService.delete(id: manager.uid, callBack: (_) {});
          await _permService.delete(id: manager.uid, callBack: (_) {});
          await FirebaseDatabase.instance.ref('users/${manager.uid}').remove();
          managers.removeWhere((m) => m.uid == manager.uid);
        }
        Loader.dismiss();
      },
    );
  }

  Future<String> _createFirebaseAuth(String email, String password) async {
    final appName = 'setup_temp_${DateTime.now().millisecondsSinceEpoch}';
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

  // ── Complete ──────────────────────────────────────────────────────────────

  Future<void> finishSetup() async {
    if (branches.isEmpty) {
      Loader.showError('setup_owner_branch_required'.tr);
      return;
    }
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

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
