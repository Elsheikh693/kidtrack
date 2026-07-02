import '../../../../index/index_main.dart';

class AuthorizedPickupController extends GetxController {
  late final AuthorizedPickupParentService _service;
  late final ChildParentService _childService;

  final RxList<AuthorizedPickupModel> items = <AuthorizedPickupModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AuthorizedPickupParentService>();
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
      items.value = list.whereType<AuthorizedPickupModel>().toList();
    });
    isLoading.value = false;
  }

  String childName(String id) => childNames[id] ?? id;

  String relationshipLabel(String r) {
    switch (r) {
      case 'father': return 'pickup_rel_father'.tr;
      case 'mother': return 'pickup_rel_mother'.tr;
      case 'grandfather': return 'pickup_rel_grandfather'.tr;
      case 'grandmother': return 'pickup_rel_grandmother'.tr;
      case 'uncle': return 'pickup_rel_uncle'.tr;
      case 'aunt': return 'pickup_rel_aunt'.tr;
      case 'driver': return 'pickup_rel_driver'.tr;
      default: return 'pickup_rel_other'.tr;
    }
  }

  void openAdd() => _openSheet(null);
  void openEdit(AuthorizedPickupModel p) => _openSheet(p);

  void _openSheet(AuthorizedPickupModel? p) {
    Get.bottomSheet(
      PickupSheet(initial: p),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
    ).then((_) => loadData());
  }

  Future<void> toggleActive(AuthorizedPickupModel p) async {
    Loader.show();
    await _service.update(
      item: p.copyWith(isActive: !p.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadData();
      },
    );
  }

  Future<void> delete(AuthorizedPickupModel p) async {
    Loader.show();
    await _service.delete(
      id: p.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('pickup_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('pickup_error_failed'.tr);
        }
      },
    );
  }
}
