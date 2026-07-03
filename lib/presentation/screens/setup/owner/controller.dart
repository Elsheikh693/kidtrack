import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class OwnerSetupController extends GetxController {
  final isLoading = false.obs;

  // ── Lists ─────────────────────────────────────────────────────────────────
  final branches = <BranchModel>[].obs;
  final managers = <StaffModel>[].obs;

  final BranchManagementService _mgmt = BranchManagementService();
  late SessionService _session;

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _loadBranches();
    _loadManagers();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadBranches() async {
    branches.value = await _mgmt.getBranches();
  }

  Future<void> _loadManagers() async {
    managers.value = await _mgmt.getManagers();
  }

  /// Manager assigned to a given branch (one manager per branch in setup).
  StaffModel? managerForBranch(String? branchId) =>
      _mgmt.managerForBranch(managers, branchId);

  // ── Add branch + its manager together ──────────────────────────────────────

  Future<void> addBranchWithManager({
    required String branchName,
    required String managerName,
    required String phone,
  }) async {
    Loader.show();
    final branchId = await _mgmt.addBranchWithManager(
      branchName: branchName,
      managerName: managerName,
      phone: phone,
      makeMain: branches.isEmpty,
    );
    if (branchId == null) {
      Loader.showError('setup_owner_branch_error'.tr);
      return;
    }
    await _loadBranches();
    await _loadManagers();
    Loader.showSuccess('setup_owner_branch_added'.tr);
  }

  Future<void> setMainBranch(String branchId) async {
    Loader.show();
    final ok = await _mgmt.setMainBranch(branches, branchId);
    Loader.dismiss();
    if (ok) {
      await _loadBranches();
    } else {
      Loader.showError('common_error'.tr);
    }
  }

  /// Deletes a branch together with its manager (staff doc, user node, perms).
  Future<void> deleteBranch(String id) async {
    Loader.show();
    final manager = managerForBranch(id);
    final ok = await _mgmt.deleteBranchWithManager(branchId: id, manager: manager);
    Loader.dismiss();
    if (!ok) {
      Loader.showError('common_error'.tr);
      return;
    }
    branches.removeWhere((b) => b.key == id);
    if (manager != null) managers.removeWhere((m) => m.uid == manager.uid);
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
