import '../../../index/index_main.dart';

class EvalLevelTemplateParentService {
  final BaseService<EvalLevelTemplateModel> _service =
      Get.find<BaseService<EvalLevelTemplateModel>>(tag: 'evalLevelTemplates');

  Future<void> getAll({
    required Function(List<EvalLevelTemplateModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required EvalLevelTemplateModel item,
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
    required EvalLevelTemplateModel item,
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
