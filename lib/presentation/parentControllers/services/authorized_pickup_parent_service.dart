import '../../../index/index_main.dart';

class AuthorizedPickupParentService {
  final BaseService<AuthorizedPickupModel> _service =
      Get.find<BaseService<AuthorizedPickupModel>>(tag: 'authorizedPickups');

  Future<void> getAll({required Function(List<AuthorizedPickupModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required AuthorizedPickupModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required AuthorizedPickupModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }
}
