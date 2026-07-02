import '../../../../index/index_main.dart';

class ChildAttendanceController extends GetxController {
  late final ChildAttendanceParentService _service;
  late final ChildParentService _childService;
  late final BranchParentService _branchService;

  final RxList<ChildAttendanceModel> items = <ChildAttendanceModel>[].obs;
  final RxList<ChildAttendanceModel> _all = <ChildAttendanceModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ChildAttendanceParentService>();
    _childService = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    _loadLookups();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  Future<void> _loadLookups() async {
    await _childService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ChildModel>()) {
          if (c.key != null) map[c.key!] = c.fullName;
        }
        childNames.value = map;
      },
    );
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

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<ChildAttendanceModel>().toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _filter() {
    final s = selectedStatus.value;
    if (s.isEmpty) {
      items.value = List.from(_all);
    } else {
      items.value = _all.where((r) => r.status == s).toList();
    }
  }

  void setStatus(String s) =>
      selectedStatus.value = (selectedStatus.value == s) ? '' : s;

  String childName(String id) => childNames[id] ?? id;
  String branchName(String id) => branchNames[id] ?? id;

  void openAdd() => _openSheet(null);
  void openEdit(ChildAttendanceModel a) => _openSheet(a);

  void _openSheet(ChildAttendanceModel? item) {
    Get.bottomSheet(
      AttendanceChildSheet(initial: item, childNames: childNames),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ChildAttendanceModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('checkin_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('checkin_error_failed'.tr);
        }
      },
    );
  }
}
