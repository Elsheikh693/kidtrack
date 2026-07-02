import '../../../../index/index_main.dart';

class MedicalListController extends GetxController {
  late final MedicalProfileParentService _service;
  late final ChildParentService _childService;

  final RxList<MedicalProfileModel> items = <MedicalProfileModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<MedicalProfileParentService>();
    _childService = Get.find<ChildParentService>();
    _loadChildren();
    loadData();
  }

  Future<void> _loadChildren() async {
    await _childService.getAll(callBack: (list) {
      final map = <String, String>{};
      for (final c in list.whereType<ChildModel>()) {
        if (c.key != null) map[c.key!] = '${c.firstName} ${c.lastName}';
      }
      childNames.value = map;
    });
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(callBack: (list) {
      items.value = list.whereType<MedicalProfileModel>().toList();
    });
    isLoading.value = false;
  }

  String childName(String id) => childNames[id] ?? id;

  void openAdd() => _openSheet(null);
  void openEdit(MedicalProfileModel m) => _openSheet(m);

  void _openSheet(MedicalProfileModel? m) {
    Get.bottomSheet(
      MedicalSheet(initial: m),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    ).then((_) => loadData());
  }

  Future<void> delete(MedicalProfileModel m) async {
    Loader.show();
    await _service.delete(
      id: m.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('medical_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('medical_error_failed'.tr);
        }
      },
    );
  }
}
