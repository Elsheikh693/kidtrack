import '../../../index/index_main.dart';

/// Manager-side CRUD for admission applications (logged-in, nursery scoped).
class OnlineApplicationParentService {
  final BaseService<OnlineApplicationModel> _service =
      Get.find<BaseService<OnlineApplicationModel>>(tag: 'onlineApplications');

  Future<void> getAll({
    required Function(List<OnlineApplicationModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required OnlineApplicationModel item,
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
    required OnlineApplicationModel item,
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
