import '../../../../index/index_main.dart';

class NurseryListController extends GetxController {
  late final NurseryParentService _service;

  final RxList<NurseryModel> items = <NurseryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<NurseryParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<NurseryModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() {
    Get.bottomSheet(
      const NurserySheet(initial: null),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  void openDetails(NurseryModel nursery) {
    Get.toNamed(nurseryDetailsView, arguments: nursery)?.then((_) => loadData());
  }

  Future<void> toggleActive(NurseryModel nursery) async {
    Loader.show();
    await _service.update(
      item: nursery.copyWith(isActive: !nursery.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadData();
      },
    );
  }

  /// Permanently removes a nursery and EVERYTHING tied to it — all its data,
  /// every owner/staff/parent account (profile + Firebase Auth), activation codes
  /// and notifications. Irreversible, so it always confirms first.
  Future<void> delete(NurseryModel nursery) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('nursery_delete_title'.tr),
        content: Text('nursery_delete_msg'.trParams({'name': nursery.name})),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common_delete'.tr,
              style: TextStyle(color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    Loader.show();
    final ok = await _service.deleteCascade(nursery.key ?? '');
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('nursery_success_deleted'.tr);
      loadData();
    } else {
      Loader.showError('nursery_error_failed'.tr);
    }
  }
}
