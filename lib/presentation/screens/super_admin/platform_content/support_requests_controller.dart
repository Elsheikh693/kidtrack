import '../../../../index/index_main.dart';

class SupportRequestsAdminController extends GetxController {
  late final SupportRequestParentService _service;

  final RxList<SupportRequestModel> items = <SupportRequestModel>[].obs;
  final RxList<SupportRequestModel> _all = <SupportRequestModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  static const List<String> statuses = [
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<SupportRequestParentService>();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<SupportRequestModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _filter() {
    final s = selectedStatus.value;
    items.value =
        s.isEmpty ? List.from(_all) : _all.where((r) => r.status == s).toList();
  }

  void setStatus(String s) =>
      selectedStatus.value = (selectedStatus.value == s) ? '' : s;

  int countOf(String status) =>
      _all.where((r) => r.status == status).length;

  void openReply(SupportRequestModel item) {
    Get.bottomSheet(
      SupportRequestReplySheet(controller: this, item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> saveReply(
    SupportRequestModel item, {
    required String status,
    required String reply,
  }) async {
    Loader.show();
    final updated = item.copyWith(
      status: status,
      adminReply: reply.trim().isEmpty ? null : reply.trim(),
    );
    await _service.update(
      item: updated,
      callBack: (res) {
        if (res == ResponseStatus.success) {
          Loader.showSuccess('srq_saved'.tr);
          loadData();
        } else {
          Loader.showError('srq_error'.tr);
        }
      },
    );
  }

  void confirmDelete(SupportRequestModel item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'srq_delete_title'.tr,
          style: Get.context!.typography.mdBold
              .copyWith(color: AppColors.textDefault),
        ),
        content: Text(
          'srq_delete_confirm'.tr,
          style: Get.context!.typography.smRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'srq_cancel'.tr,
              style: Get.context!.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _doDelete(item.key ?? '');
            },
            child: Text(
              'srq_delete'.tr,
              style: Get.context!.typography.smSemiBold
                  .copyWith(color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doDelete(String id) async {
    Loader.show();
    await _service.delete(
      id: id,
      callBack: (res) {
        if (res == ResponseStatus.success) {
          Loader.showSuccess('srq_deleted'.tr);
          loadData();
        } else {
          Loader.showError('srq_error'.tr);
        }
      },
    );
  }
}
