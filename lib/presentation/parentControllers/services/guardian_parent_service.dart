import '../../../index/index_main.dart';

class GuardianParentService {
  final BaseService<ParentModel> _service =
      Get.find<BaseService<ParentModel>>(tag: 'parents');

  Future<void> getAll({required Function(List<ParentModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ParentModel item,
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
    required ParentModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String uid,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: uid, voidCallBack: callBack);
  }
}
