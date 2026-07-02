import '../../../../index/index_main.dart';

class StaffPermissionsController extends GetxController {
  late BaseService<PermissionSetModel> _permService;
  late StaffModel staff;

  final RxMap<String, bool> permissions = <String, bool>{}.obs;
  final RxBool isLoading = true.obs;
  String? _existingKey;

  @override
  void onInit() {
    super.onInit();
    _permService = Get.find<BaseService<PermissionSetModel>>(tag: 'permissionSets');
    staff = Get.arguments as StaffModel;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await _permService.getData(
      data: {},
      voidCallBack: (list) {
        final found = list
            .whereType<PermissionSetModel>()
            .toList()
            .firstWhereOrNull((p) => p.employeeId == staff.uid);
        if (found != null) {
          _existingKey = found.key ?? staff.uid;
          permissions.value = {
            for (final k in PermissionKeys.all) k: false,
            ...found.permissions,
          };
        } else {
          permissions.value = Map.from(
            PermissionTemplates.forTemplate(staff.template),
          );
        }
      },
    );
    isLoading.value = false;
  }

  void toggle(String key) {
    permissions[key] = !(permissions[key] ?? false);
  }

  Future<void> save() async {
    Loader.show();
    final id = _existingKey ?? staff.uid;
    final model = PermissionSetModel(
      key: id,
      employeeId: staff.uid,
      permissions: Map.from(permissions),
    );
    if (_existingKey != null) {
      await _permService.updateData(
        item: model,
        toJson: (p) => p.toJson(),
        id: id,
        voidCallBack: (status) {
          if (status == ResponseStatus.success) {
            Loader.showSuccess('perm_save_success'.tr);
            Get.back();
          } else {
            Loader.showError('perm_save_error'.tr);
          }
        },
      );
    } else {
      _existingKey = id;
      await _permService.addData(
        item: model,
        toJson: (p) => p.toJson(),
        id: id,
        voidCallBack: (status) {
          if (status == ResponseStatus.success) {
            Loader.showSuccess('perm_save_success'.tr);
            Get.back();
          } else {
            Loader.showError('perm_save_error'.tr);
          }
        },
      );
    }
  }
}
