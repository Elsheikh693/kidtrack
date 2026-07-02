import '../../../../index/index_main.dart';

class WaitingListController extends GetxController {
  late final WaitingListParentService _service;

  final RxList<WaitingListModel> items = <WaitingListModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<WaitingListParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(callBack: (list) {
      items.value = list.whereType<WaitingListModel>().toList();
    });
    isLoading.value = false;
  }

  String statusLabel(String s) {
    switch (s) {
      case 'pending': return 'waiting_status_pending'.tr;
      case 'contacted': return 'waiting_status_contacted'.tr;
      case 'enrolled': return 'waiting_status_enrolled'.tr;
      case 'cancelled': return 'waiting_status_cancelled'.tr;
      default: return s;
    }
  }

  Color statusColor(String s) {
    switch (s) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'contacted': return const Color(0xFF6366F1);
      case 'enrolled': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void openAdd() => _openSheet(null);
  void openEdit(WaitingListModel w) => _openSheet(w);

  void _openSheet(WaitingListModel? w) {
    Get.bottomSheet(
      WaitingSheet(initial: w),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    ).then((_) => loadData());
  }

  Future<void> delete(WaitingListModel w) async {
    Loader.show();
    await _service.delete(
      id: w.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('waiting_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('waiting_error_failed'.tr);
        }
      },
    );
  }
}
