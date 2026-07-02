import '../../../../index/index_main.dart';

class GuardianListController extends GetxController {
  late final GuardianParentService _service;

  final RxList<ParentModel> items = <ParentModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<GuardianParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(callBack: (list) {
      items.value = list.whereType<ParentModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
    isLoading.value = false;
  }

  Future<void> toggleActive(ParentModel p) async {
    Loader.show();
    await _service.update(
      item: p.copyWith(isActive: !p.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadData();
      },
    );
  }

  void openEdit(ParentModel p) {
    Get.bottomSheet(
      GuardianSheet(initial: p),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    ).then((_) => loadData());
  }

  void openCreate() {
    Get.bottomSheet(
      const ParentCreateSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((result) { if (result == true) loadData(); });
  }
}
