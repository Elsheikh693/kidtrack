import '../../../index/index_main.dart';

class ChildStateTemplateParentService {
  final BaseService<ChildStateTemplateModel> _service =
      Get.find<BaseService<ChildStateTemplateModel>>(tag: 'childStateTemplates');

  Future<void> getAll({
    required Function(List<ChildStateTemplateModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ChildStateTemplateModel item,
    required Function(ResponseStatus) callBack,
    bool silent = false,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
      silent: silent,
    );
  }

  Future<void> update({
    required ChildStateTemplateModel item,
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
