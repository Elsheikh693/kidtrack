import '../../../../index/index_main.dart';

class StaffListController extends GetxController {
  late final StaffParentService _staffService;
  late final BranchParentService _branchService;

  final _session = SessionService();

  final RxList<StaffModel> staffList = <StaffModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _staffService = Get.find<StaffParentService>();
    _branchService = Get.find<BranchParentService>();
    _loadBranches();
    loadStaff();
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final b in list.whereType<BranchModel>()) {
          if (b.key != null) map[b.key!] = b.name;
        }
        branchNames.value = map;
      },
    );
  }

  Future<void> loadStaff() async {
    isLoading.value = true;
    await _staffService.getAll(
      callBack: (list) {
        staffList.value = list.whereType<StaffModel>().where(_inScope).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  /// Owner/super-admin see every branch; a branch manager (or receptionist)
  /// only sees their own branch and shift.
  bool _inScope(StaffModel s) {
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final bId = _session.branchId;
    if (bId != null && bId.isNotEmpty && s.branchId != bId) return false;
    return _session.seesShift(s.shift);
  }

  String branchName(String? id) => id == null
      ? 'staff_no_branch'.tr
      : (branchNames[id] ?? 'staff_no_branch'.tr);

  Future<void> toggleActive(StaffModel staff) async {
    await _staffService.update(
      item: staff.copyWith(isActive: !staff.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadStaff();
      },
    );
  }

  void openAdd() => _openSheet(null);

  void openEdit(StaffModel s) => _openSheet(s);

  void openPermissions(StaffModel s) =>
      Get.toNamed(staffPermissionsView, arguments: s);

  void _openSheet(StaffModel? staff) {
    Get.toNamed(staffFormView, arguments: staff)?.then((_) => loadStaff());
  }
}
