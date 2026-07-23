import '../../../index/index_main.dart';

class DailyAssessmentParentService {
  final BaseService<DailyAssessmentModel> _service =
      Get.find<BaseService<DailyAssessmentModel>>(tag: 'dailyAssessments');

  Future<void> getAll({
    required Function(List<DailyAssessmentModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required DailyAssessmentModel item,
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
