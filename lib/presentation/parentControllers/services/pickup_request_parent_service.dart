import '../../../index/index_main.dart';

class PickupRequestParentService {
  final BaseService<PickupRequestModel> _service =
      Get.find<BaseService<PickupRequestModel>>(tag: 'pickupRequests');

  Future<void> getAll({
    required Function(List<PickupRequestModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required PickupRequestModel item,
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
    required PickupRequestModel item,
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
