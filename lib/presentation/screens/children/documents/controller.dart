import '../../../../index/index_main.dart';

class DocumentListController extends GetxController {
  late final DocumentParentService _service;
  late final ChildParentService _childService;

  final RxList<DocumentModel> items = <DocumentModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<DocumentParentService>();
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
      items.value = list.whereType<DocumentModel>().toList();
    });
    isLoading.value = false;
  }

  String childName(String id) => childNames[id] ?? id;

  String typeLabel(String type) {
    switch (type) {
      case 'birth_certificate': return 'document_type_birth'.tr;
      case 'id': return 'document_type_id'.tr;
      case 'vaccination': return 'document_type_vaccination'.tr;
      case 'medical': return 'document_type_medical'.tr;
      default: return 'document_type_other'.tr;
    }
  }

  void openAdd() => _openSheet(null);
  void openEdit(DocumentModel d) => _openSheet(d);

  void _openSheet(DocumentModel? d) {
    Get.bottomSheet(
      DocumentSheet(initial: d),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    ).then((_) => loadData());
  }

  Future<void> delete(DocumentModel d) async {
    Loader.show();
    await _service.delete(
      id: d.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('document_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('document_error_failed'.tr);
        }
      },
    );
  }
}
