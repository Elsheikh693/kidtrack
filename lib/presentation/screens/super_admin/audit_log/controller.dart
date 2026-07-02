import '../../../../index/index_main.dart';

class AuditLogController extends GetxController {
  late final AuditLogParentService _service;

  final RxList<AuditLogModel> items = <AuditLogModel>[].obs;
  final RxList<AuditLogModel> _all = <AuditLogModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedAction = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AuditLogParentService>();
    loadData();
    ever(selectedAction, (_) => _filter());
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<AuditLogModel>().toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _filter() {
    final a = selectedAction.value;
    if (a.isEmpty) {
      items.value = List.from(_all);
    } else {
      items.value = _all.where((r) => r.action == a).toList();
    }
  }

  void setAction(String a) =>
      selectedAction.value = (selectedAction.value == a) ? '' : a;
}
