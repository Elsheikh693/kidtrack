import '../../../index/index_main.dart';

class ChildLeaveRequestParentService {
  final BaseService<ChildLeaveRequestModel> _service =
      Get.find<BaseService<ChildLeaveRequestModel>>(tag: 'childLeaveRequests');

  Future<void> getAll({required Function(List<ChildLeaveRequestModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ChildLeaveRequestModel item,
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
    required ChildLeaveRequestModel item,
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
