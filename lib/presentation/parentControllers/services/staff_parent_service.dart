import '../../../index/index_main.dart';

class StaffParentService {
  final BaseService<StaffModel> _service =
      Get.find<BaseService<StaffModel>>(tag: 'staff');

  Future<void> add({
    required StaffModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required StaffModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> getAll({
    required Function(List<StaffModel?>) callBack,
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
