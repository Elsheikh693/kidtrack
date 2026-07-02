import '../../../../index/index_main.dart';

class ChildStatesController extends GetxController {
  late final ChildStateTemplateParentService _service;

  final RxList<ChildStateTemplateModel> items =
      <ChildStateTemplateModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ChildStateTemplateParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ChildStateTemplateModel>().toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(ChildStateTemplateModel item) => _openSheet(item);

  void _openSheet(ChildStateTemplateModel? item) {
    Get.bottomSheet(
      ChildStateSheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ChildStateTemplateModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('child_state_deleted'.tr);
          loadData();
        } else {
          Loader.showError('child_state_error'.tr);
        }
      },
    );
  }

  Future<void> toggle(ChildStateTemplateModel item) async {
    final updated = item.copyWith(isActive: !item.isActive);
    await _service.update(
      item: updated,
      callBack: (status) {
        if (status == ResponseStatus.success) loadData();
      },
    );
  }
}
