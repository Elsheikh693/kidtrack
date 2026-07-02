import '../../../../index/index_main.dart';

class ChildLeaveRequestController extends GetxController {
  late final ChildLeaveRequestParentService _service;
  late final ChildParentService _childService;

  final RxList<ChildLeaveRequestModel> items = <ChildLeaveRequestModel>[].obs;
  final RxList<ChildLeaveRequestModel> _all = <ChildLeaveRequestModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ChildLeaveRequestParentService>();
    _childService = Get.find<ChildParentService>();
    _loadChildren();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  Future<void> _loadChildren() async {
    await _childService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ChildModel>()) {
          if (c.key != null) map[c.key!] = c.fullName;
        }
        childNames.value = map;
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<ChildLeaveRequestModel>().toList()
          ..sort((a, b) => b.createdAt!.compareTo(a.createdAt ?? 0));
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

  void openAdd() => _openSheet(null);
  void openEdit(ChildLeaveRequestModel item) => _openSheet(item);

  void _openSheet(ChildLeaveRequestModel? item) {
    Get.bottomSheet(
      ChildLeaveSheet(initial: item, childNames: childNames),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> updateStatus(
    ChildLeaveRequestModel item,
    String newStatus,
  ) async {
    Loader.show();
    final updated = item.copyWith(status: newStatus);
    await _service.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          final key =
              newStatus == 'approved'
                  ? 'child_leave_approved_success'
                  : 'child_leave_rejected_success';
          Loader.showSuccess(key.tr);
          loadData();
        } else {
          Loader.showError('child_leave_error_failed'.tr);
        }
      },
    );
  }

  Future<void> delete(ChildLeaveRequestModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('child_leave_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('child_leave_error_failed'.tr);
        }
      },
    );
  }
}
