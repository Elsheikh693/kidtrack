import '../../../index/index_main.dart';

/// CRUD over nursery-wide assessment templates (the reusable plans).
class AssessmentTemplateParentService {
  final BaseService<AssessmentTemplateModel> _service =
      Get.find<BaseService<AssessmentTemplateModel>>(tag: 'assessmentTemplates');

  Future<void> getAll({
    required Function(List<AssessmentTemplateModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required AssessmentTemplateModel item,
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
    required AssessmentTemplateModel item,
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
