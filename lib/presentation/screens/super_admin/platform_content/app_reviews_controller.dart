import '../../../../index/index_main.dart';

class AppReviewsAdminController extends GetxController {
  late final AppReviewParentService _service;

  final RxList<AppReviewModel> items = <AppReviewModel>[].obs;
  final RxList<AppReviewModel> _all = <AppReviewModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  static const List<String> statuses = ['new', 'read', 'replied'];

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AppReviewParentService>();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  double get averageRating {
    if (_all.isEmpty) return 0;
    final sum = _all.fold<int>(0, (acc, r) => acc + r.rating);
    return sum / _all.length;
  }

  int get total => _all.length;

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<AppReviewModel>().toList()
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

  int countOf(String status) => _all.where((r) => r.status == status).length;

  void openReply(AppReviewModel item) {
    // Opening a "new" review marks it read so the badge count stays meaningful.
    if (item.status == 'new') {
      _service.update(item: item.copyWith(status: 'read'), callBack: (_) {});
    }
    Get.bottomSheet(
      AppReviewReplySheet(controller: this, item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> saveReply(
    AppReviewModel item, {
    required String reply,
  }) async {
    Loader.show();
    final trimmed = reply.trim();
    final updated = item.copyWith(
      status: trimmed.isEmpty ? 'read' : 'replied',
      adminReply: trimmed.isEmpty ? null : trimmed,
    );
    await _service.update(
      item: updated,
      callBack: (res) {
        if (res == ResponseStatus.success) {
          Loader.showSuccess('arv_saved'.tr);
          loadData();
        } else {
          Loader.showError('arv_error'.tr);
        }
      },
    );
  }

  void confirmDelete(AppReviewModel item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'arv_delete_title'.tr,
          style: Get.context!.typography.mdBold
              .copyWith(color: AppColors.textDefault),
        ),
        content: Text(
          'arv_delete_confirm'.tr,
          style: Get.context!.typography.smRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'arv_cancel'.tr,
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
              'arv_delete'.tr,
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
          Loader.showSuccess('arv_deleted'.tr);
          loadData();
        } else {
          Loader.showError('arv_error'.tr);
        }
      },
    );
  }
}
