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

    // Reuse the identity if this phone already exists (branch manager who is also
    // a guardian, or staff at another nursery) instead of colliding on the email.
    final String uid;
    try {
      final res = await Get.find<IdentityService>()
          .resolveByPhone(phone: phone, name: managerName);
      uid = res.uid;
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

    await Get.find<IdentityService>().attachMembership(
      uid: uid,
      role: UserType.branchManager.name,
      nurseryId: nurseryId,
      branchId: branchId,
      name: managerName,
      phone: phone,
    );

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
      // Drop only this branch-manager hat; keep the identity if the person still
      // holds another membership (guardian here, or staff at another nursery).
      final identity = Get.find<IdentityService>();
      await identity.removeMembership(
        uid: manager.uid,
        nurseryId: manager.nurseryId,
        role: manager.role.name,
      );
      final remaining = await identity.memberships(manager.uid);
      if (remaining.isEmpty) {
        await FirebaseDatabase.instance.ref('users/${manager.uid}').remove();
      }
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
}
