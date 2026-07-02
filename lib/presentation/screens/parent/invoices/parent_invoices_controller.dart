import '../../../../index/index_main.dart';

class ParentInvoicesController extends GetxController {
  final _service = Get.find<InvoiceParentService>();

  final RxList<InvoiceModel> items = <InvoiceModel>[].obs;
  final RxList<InvoiceModel> _all = <InvoiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  // Summary
  final RxDouble totalDue = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxInt overdueCount = 0.obs;

  String get _childId => Get.find<ActiveChildService>().childId.value;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    loadData();
    ever(selectedStatus, (_) => _filter());
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) => loadData(),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list
            .whereType<InvoiceModel>()
            .where((i) => i.childId == _childId)
            .toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        _computeSummary();
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _computeSummary() {
    totalDue.value = _all
        .where((i) => i.status != 'paid' && i.status != 'cancelled')
        .fold(0, (s, i) => s + i.totalAmount);
    totalPaid.value = _all
        .where((i) => i.status == 'paid')
        .fold(0, (s, i) => s + i.totalAmount);
    overdueCount.value = _all.where((i) => i.status == 'overdue').length;
  }

  void _filter() {
    final s = selectedStatus.value;
    if (s.isEmpty) {
      items.value = List.from(_all);
    } else {
      items.value = _all.where((i) => i.status == s).toList();
    }
  }

  void setStatus(String s) =>
      selectedStatus.value = (selectedStatus.value == s) ? '' : s;

  List<InvoiceModel> get pendingReminders {
    final list = _all
        .where((i) => i.status == 'pending' || i.status == 'overdue')
        .toList()
      ..sort((a, b) {
        if (a.status == 'overdue' && b.status != 'overdue') return -1;
        if (b.status == 'overdue' && a.status != 'overdue') return 1;
        return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
      });
    return list;
  }
}
