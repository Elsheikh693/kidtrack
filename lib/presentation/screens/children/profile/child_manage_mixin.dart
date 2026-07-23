part of 'controller.dart';

/// Enrollment-management actions on the profiled child — change classroom,
/// change fee package(s), move to another branch, and permanent delete. Kept
/// out of the controller body (same library via `part`) so the controller
/// stays a thin orchestrator over the profile loaders.
///
/// Lookup options (branches / classrooms / packages) are fetched lazily the
/// first time a management sheet opens, then filtered per branch in memory.
mixin ChildManageMixin on GetxController {
  // ── Lookup state ────────────────────────────────────────────────────────
  final manageBranches = <BranchModel>[].obs;
  final isManageLoading = false.obs;

  // Full lookup caches; filtered per branch by the getters below.
  final _allPrograms = <ProgramModel>[];
  final _allClassrooms = <ClassroomModel>[];
  final _allPackages = <PackageModel>[];

  late final ChildParentService _mChildSvc;
  late final BranchParentService _mBranchSvc;
  late final ProgramParentService _mProgramSvc;
  late final ClassroomParentService _mClassSvc;
  late final PackageParentService _mPackageSvc;
  late final ChildWithdrawalService _mDeleteSvc;

  /// The child currently shown — supplied by the host controller.
  ChildModel? get manageChild;

  /// Reloads the profile after a successful mutation — supplied by the host.
  Future<void> reloadProfile();

  void initManage() {
    _mChildSvc = Get.find<ChildParentService>();
    _mBranchSvc = Get.find<BranchParentService>();
    _mProgramSvc = Get.find<ProgramParentService>();
    _mClassSvc = Get.find<ClassroomParentService>();
    _mPackageSvc = Get.find<PackageParentService>();
    _mDeleteSvc = Get.find<ChildWithdrawalService>();
  }

  /// Active levels/programs available in [branchId] (all-branch levels
  /// included), name-sorted.
  List<ProgramModel> programsFor(String branchId) => _allPrograms
      .where((p) =>
          p.isActive && (p.isAllBranches || p.branchIds.contains(branchId)))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  /// Active classrooms available in [branchId], optionally narrowed to those
  /// belonging to [programId] (mirrors the add-child filtering). Name-sorted.
  List<ClassroomModel> classroomsFor(String branchId, {String? programId}) =>
      _allClassrooms.where((c) {
        final branchOk =
            c.isActive && (c.isAllBranches || c.branchIds.contains(branchId));
        final programOk = programId == null ||
            c.programIds.isEmpty ||
            c.programIds.contains(programId);
        return branchOk && programOk;
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  /// Active fee packages available in [branchId] (all-branch packages
  /// included), name-sorted.
  List<PackageModel> packagesFor(String branchId) => _allPackages
      .where((p) =>
          p.isActive &&
          (p.branchId == null || p.branchId!.isEmpty || p.branchId == branchId))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  /// Loads branches, classrooms and packages once per open. Cheap enough to run
  /// on every sheet open — correctness over a micro-cache that could go stale.
  Future<void> loadManageLookups() async {
    isManageLoading.value = true;
    await _mBranchSvc.getAll(callBack: (list) {
      manageBranches.value = list.whereType<BranchModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
    await _mProgramSvc.getAll(callBack: (list) {
      _allPrograms
        ..clear()
        ..addAll(list.whereType<ProgramModel>());
    });
    await _mClassSvc.getAll(callBack: (list) {
      _allClassrooms
        ..clear()
        ..addAll(list.whereType<ClassroomModel>());
    });
    await _mPackageSvc.getAll(callBack: (list) {
      _allPackages
        ..clear()
        ..addAll(list.whereType<PackageModel>());
    });
    isManageLoading.value = false;
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Moves the child to [target] classroom (within the same branch).
  Future<void> changeClassroom(ClassroomModel target) async {
    final c = manageChild;
    if (c == null || c.key == null) return;
    Get.back();
    if (c.classroomId == target.key) return;
    await _persist(
      c.copyWith(classroomId: target.key),
      'child_manage_classroom_success',
    );
  }

  /// Replaces the child's subscribed fee packages. Requires at least one id —
  /// the RTDB PATCH update can't clear an omitted key, so the sheet keeps the
  /// Save button disabled while the selection is empty.
  Future<void> changePackages(List<String> ids) async {
    final c = manageChild;
    if (c == null || c.key == null || ids.isEmpty) return;
    Get.back();
    await _persist(
      c.copyWith(packageIds: ids),
      'child_manage_package_success',
    );
  }

  /// Moves the child to [branch] and re-configures them for it: a [classroom]
  /// and at least one [packageIds] are always picked (the new branch is often
  /// priced differently), and an optional [program] level. A classroom + a
  /// package are always chosen so nothing from the old branch lingers; the
  /// level is left untouched when [program] is null (an omitted PATCH key can't
  /// clear the stored value).
  Future<void> changeBranch({
    required BranchModel branch,
    ProgramModel? program,
    required ClassroomModel classroom,
    required List<String> packageIds,
  }) async {
    final c = manageChild;
    if (c == null || c.key == null || packageIds.isEmpty) return;
    Get.back();
    await _persist(
      c.copyWith(
        branchId: branch.key,
        classroomId: classroom.key,
        programId: program?.key,
        packageIds: packageIds,
      ),
      'child_manage_branch_success',
    );
  }

  /// Permanently deletes the child (no departure record). The server-side
  /// cleanup mirrors withdrawal — child data + orphaned parents + their Auth.
  /// On success the profile pops back to the list, which reloads and drops it.
  Future<void> deleteChild() async {
    final c = manageChild;
    if (c == null || c.key == null) return;
    Loader.show();
    final ok = await _mDeleteSvc.deleteChild(childId: c.key!);
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('child_delete_success'.tr);
      Get.back();
    } else {
      Loader.showError('child_delete_error'.tr);
    }
  }

  Future<void> _persist(ChildModel updated, String successKey) async {
    Loader.show();
    await _mChildSvc.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          reloadProfile();
          Loader.showSuccess(successKey.tr);
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }
}
