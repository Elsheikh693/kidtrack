import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Single source of truth for creating, editing, and deleting nursery branches
/// and their branch-manager accounts. Shared by the owner setup flow and the
/// manager nursery-profile branches editor so both write the same canonical
/// records under `platform/{nurseryId}/branches`.
class BranchManagementService {
  final BranchParentService _branchService = Get.find<BranchParentService>();
  final StaffParentService _staffService = Get.find<StaffParentService>();
  final PermissionParentService _permService =
      Get.find<PermissionParentService>();
  final SessionService _session = Get.find<SessionService>();

  Future<List<BranchModel>> getBranches() async {
    var result = <BranchModel>[];
    await _branchService.getAll(callBack: (list) {
      result = list.whereType<BranchModel>().toList();
    });
    return result;
  }

  Future<List<StaffModel>> getManagers() async {
    var result = <StaffModel>[];
    await _staffService.getAll(callBack: (list) {
      result = list
          .whereType<StaffModel>()
          .where((s) => s.role == UserType.branchManager)
          .toList();
    });
    return result;
  }

  StaffModel? managerForBranch(List<StaffModel> managers, String? branchId) =>
      managers.firstWhereOrNull((m) => m.branchId == branchId);

  /// Creates a branch together with its branch-manager auth account, staff
  /// record, user node, and permission set. Returns the new branch id on
  /// success, or null if any step fails.
  Future<String?> addBranchWithManager({
    required String branchName,
    required String managerName,
    required String phone,
    required bool makeMain,
  }) async {
    final nurseryId = _session.nurseryId ?? '';
    final branchId = const Uuid().v4();
    final email = '$phone@gmail.com';

    String uid;
    try {
      uid = await _createFirebaseAuth(email, phone);
    } catch (_) {
      return null;
    }

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
    if (!branchOk) return null;

    bool staffOk = false;
    await _staffService.add(
      item: StaffModel(
        uid: uid,
        nurseryId: nurseryId,
        branchId: branchId,
        name: managerName,
        phone: phone.isEmpty ? null : phone,
        role: UserType.branchManager,
        template: StaffTemplate.branchManager,
      ),
      callBack: (status) => staffOk = status == ResponseStatus.success,
    );
    if (!staffOk) return null;

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
      callBack: (_) {},
    );

    return branchId;
  }

  /// Persists edited branch details (name / address / phone / whatsapp /
  /// location). Keeps identity fields (key, isMain, manager) untouched.
  Future<bool> updateBranch(BranchModel branch) async {
    bool ok = false;
    await _branchService.update(
      item: branch,
      callBack: (status) => ok = status == ResponseStatus.success,
    );
    return ok;
  }

  Future<bool> setMainBranch(List<BranchModel> branches, String branchId) async {
    final target = branches.firstWhereOrNull((b) => b.key == branchId);
    if (target == null || target.isMain) return false;
    await _clearMainFlag(branches);
    return updateBranch(target.copyWith(isMain: true));
  }

  /// Deletes a branch together with its manager (staff doc, user node, perms).
  Future<bool> deleteBranchWithManager({
    required String branchId,
    StaffModel? manager,
  }) async {
    bool ok = false;
    await _branchService.delete(
      id: branchId,
      callBack: (status) => ok = status == ResponseStatus.success,
    );
    if (!ok) return false;
    if (manager != null) {
      await _staffService.delete(id: manager.uid, callBack: (_) {});
      await _permService.delete(id: manager.uid, callBack: (_) {});
      await FirebaseDatabase.instance.ref('users/${manager.uid}').remove();
    }
    return true;
  }

  Future<void> _clearMainFlag([List<BranchModel>? known]) async {
    final branches = known ?? await getBranches();
    for (final b in branches.where((b) => b.isMain)) {
      await _branchService.update(
        item: b.copyWith(isMain: false),
        callBack: (_) {},
      );
    }
  }

  /// Creates the manager's Firebase Auth account on a throwaway secondary app
  /// so the current (owner/manager) session is never signed out.
  Future<String> _createFirebaseAuth(String email, String password) async {
    final appName = 'branchmgmt_temp_${DateTime.now().millisecondsSinceEpoch}';
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
}
