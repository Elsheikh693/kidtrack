import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import 'widgets/cd_transfer_sheet.dart';
import 'widgets/cd_assign_teacher_sheet.dart';

class ClassroomDetailController extends GetxController {
  ClassroomDetailController({required this.classroom});
  final ClassroomModel classroom;

  late final ChildParentService _childService;
  late final StaffParentService _staffService;
  late final ClassroomParentService _classroomService;
  final _session = SessionService();

  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxList<StaffModel> teachers = <StaffModel>[].obs;
  final RxList<ClassroomModel> otherClassrooms = <ClassroomModel>[].obs;
  final RxBool isChildrenLoading = true.obs;
  final RxBool isTeachersLoading = true.obs;

  // multi-select
  final RxBool selectMode = false.obs;
  final RxSet<String> selected = <String>{}.obs;

  bool get allSelected =>
      children.isNotEmpty && selected.length == children.length;

  @override
  void onInit() {
    super.onInit();
    _childService = Get.find<ChildParentService>();
    _staffService = Get.find<StaffParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadChildren(), loadTeachers(), _loadOtherClassrooms()]);
  }

  Future<void> loadChildren() async {
    isChildrenLoading.value = true;
    await _childService.getAll(callBack: (list) {
      children.value = list
          .whereType<ChildModel>()
          // Branches are fully separate: a shared/same-named classroom must
          // never surface another branch's children (owners see all).
          .where((c) =>
              c.classroomId == classroom.key && _session.seesBranch(c.branchId))
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
    });
    isChildrenLoading.value = false;
  }

  Future<void> loadTeachers() async {
    isTeachersLoading.value = true;
    await _staffService.getAll(callBack: (list) {
      teachers.value = list
          .whereType<StaffModel>()
          .where((s) =>
              s.classroomId == classroom.key && _session.seesBranch(s.branchId))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
    isTeachersLoading.value = false;
  }

  Future<void> _loadOtherClassrooms() async {
    // Transfer targets must stay inside the current user's branch — a child can
    // never be moved into another branch's classroom (which would also leave
    // its branchId inconsistent with the new classroom). Owners/unscoped users
    // (empty session branch) still see every classroom.
    final myBranch = _session.branchId ?? '';
    await _classroomService.getAll(callBack: (list) {
      otherClassrooms.value = list
          .whereType<ClassroomModel>()
          .where((c) =>
              c.key != classroom.key &&
              c.isActive &&
              (myBranch.isEmpty ||
                  c.isAllBranches ||
                  c.branchIds.contains(myBranch)))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // ── Select mode ───────────────────────────────────────────────────────────

  void toggleSelectMode() {
    selectMode.toggle();
    if (!selectMode.value) selected.clear();
  }

  void toggleChild(String key) {
    if (selected.contains(key)) {
      selected.remove(key);
    } else {
      selected.add(key);
    }
    selected.refresh();
  }

  void toggleSelectAll() {
    if (allSelected) {
      selected.clear();
    } else {
      for (final c in children) {
        if (c.key != null) selected.add(c.key!);
      }
    }
    selected.refresh();
  }

  // ── Transfer ──────────────────────────────────────────────────────────────

  void openTransfer(ChildModel child) {
    _showTransferSheet(onSelect: (target) => _transferSingle(child, target));
  }

  void openBulkTransfer() {
    if (selected.isEmpty) return;
    _showTransferSheet(count: selected.length, onSelect: _bulkTransfer);
  }

  void _showTransferSheet({
    required Function(ClassroomModel) onSelect,
    int? count,
  }) {
    Get.bottomSheet(
      CdTransferSheet(
        classrooms: otherClassrooms,
        onSelect: onSelect,
        count: count,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  Future<void> _transferSingle(ChildModel child, ClassroomModel target) async {
    Get.back();
    Loader.show();
    await _childService.update(
      item: child.copyWith(classroomId: target.key),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('cd_transfer_success'.tr);
          loadChildren();
        } else {
          Loader.showError('cd_error'.tr);
        }
      },
    );
  }

  Future<void> _bulkTransfer(ClassroomModel target) async {
    Get.back();
    final ids = selected.toList();
    Loader.show();
    final toTransfer = children
        .where((c) => c.key != null && ids.contains(c.key))
        .toList();

    for (final child in toTransfer) {
      await _childService.update(
        item: child.copyWith(classroomId: target.key),
        callBack: (_) {},
      );
    }
    Loader.dismiss();
    Loader.showSuccess('cd_bulk_success'.tr);
    selectMode.value = false;
    selected.clear();
    loadChildren();
  }

  // ── Teacher assignment ────────────────────────────────────────────────────

  void openAssignTeacher() async {
    final List<StaffModel> allStaff = [];
    await _staffService.getAll(callBack: (list) {
      allStaff.addAll(list.whereType<StaffModel>());
    });

    final assignedIds = teachers.map((t) => t.uid).toSet();
    final available = allStaff
        .where((s) => !assignedIds.contains(s.uid) && s.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    Get.bottomSheet(
      CdAssignTeacherSheet(
        available: available,
        onAssign: _assignTeacher,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  Future<void> _assignTeacher(StaffModel staff) async {
    Get.back();
    Loader.show();
    await _staffService.update(
      item: staff.copyWith(classroomId: classroom.key),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('cd_teacher_assigned'.tr);
          loadTeachers();
        } else {
          Loader.showError('cd_error'.tr);
        }
      },
    );
  }

  Future<void> removeTeacher(StaffModel staff) async {
    Loader.show();
    try {
      await FirebaseDatabase.instance
          .ref('${ApiConstants.staff}/${staff.uid}/classroomId')
          .remove();
      Loader.dismiss();
      Loader.showSuccess('cd_teacher_removed'.tr);
      loadTeachers();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('cd_error'.tr);
    }
  }
}
