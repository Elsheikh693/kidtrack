import '../../../index/index_main.dart';

class PermissionParentService {
  final BaseService<PermissionSetModel> _service =
      Get.find<BaseService<PermissionSetModel>>(tag: 'permissionSets');

  Future<void> add({
    required PermissionSetModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.employeeId,
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required PermissionSetModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.employeeId,
      voidCallBack: callBack,
    );
  }

  Future<void> getAll({
    required Function(List<PermissionSetModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }
}
