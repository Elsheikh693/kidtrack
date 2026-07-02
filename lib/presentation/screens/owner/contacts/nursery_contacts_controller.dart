import '../../../../index/index_main.dart';

class NurseryContactsController extends GetxController {
  late final _service =
      Get.find<BaseService<NurseryContactModel>>(tag: 'nurseryContacts');

  final RxList<NurseryContactModel> items = <NurseryContactModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        items.value = list.whereType<NurseryContactModel>().toList()
          ..sort((a, b) {
            if (a.order != b.order) return a.order.compareTo(b.order);
            return (a.createdAt ?? 0).compareTo(b.createdAt ?? 0);
          });
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(NurseryContactModel item) => _openSheet(item);

  void _openSheet(NurseryContactModel? item) {
    Get.bottomSheet(
      NurseryContactSheet(existing: item, nextOrder: items.length),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(NurseryContactModel item) async {
    Loader.show();
    await _service.deleteData(
      id: item.key ?? '',
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('nursery_contact_deleted'.tr);
          loadData();
        } else {
          Loader.showError('nursery_contact_error'.tr);
        }
      },
    );
  }
}
