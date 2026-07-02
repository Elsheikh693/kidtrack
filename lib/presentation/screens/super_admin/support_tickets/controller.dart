import '../../../../index/index_main.dart';

class SupportTicketController extends GetxController {
  late final SupportTicketParentService _service;

  final RxList<SupportTicketModel> items = <SupportTicketModel>[].obs;
  final RxList<SupportTicketModel> _all = <SupportTicketModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<SupportTicketParentService>();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<SupportTicketModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
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

  void openAdd() => _openSheet(null);
  void openReply(SupportTicketModel item) => _openSheet(item);

  void _openSheet(SupportTicketModel? item) {
    final session = SessionService();
    Get.bottomSheet(
      SupportTicketSheet(
        existing: item,
        nurseryId: session.nurseryId ?? '',
        submittedBy: session.userId ?? '',
        isReplyMode: item != null,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ).then((_) => loadData());
  }

  Future<void> updateStatus(SupportTicketModel item, String newStatus) async {
    Loader.show();
    final updated = item.copyWith(status: newStatus);
    await _service.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('ticket_success_updated'.tr);
          loadData();
        } else {
          Loader.showError('ticket_error_failed'.tr);
        }
      },
    );
  }

  Future<void> delete(SupportTicketModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('ticket_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('ticket_error_failed'.tr);
        }
      },
    );
  }
}
