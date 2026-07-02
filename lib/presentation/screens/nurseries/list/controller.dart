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

  Future<void> delete(NurseryModel nursery) async {
    Loader.show();
    await _service.delete(
      id: nursery.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('nursery_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('nursery_error_failed'.tr);
        }
      },
    );
  }
}
