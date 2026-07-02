import '../../../index/index_main.dart';

class ParentChildParentService {
  final BaseService<ParentChildModel> _service =
      Get.find<BaseService<ParentChildModel>>(tag: 'parentChildren');

  Future<void> getAll({required Function(List<ParentChildModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ParentChildModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
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
