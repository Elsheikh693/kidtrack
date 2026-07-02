import '../../../../index/index_main.dart';

class AboutUsController extends GetxController {
  late final AboutUsParentService _service;

  final Rxn<AboutUsModel> about = Rxn<AboutUsModel>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AboutUsParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        final items = list.whereType<AboutUsModel>().toList();
        about.value = items.isNotEmpty ? items.first : null;
      },
    );
    isLoading.value = false;
  }
}
