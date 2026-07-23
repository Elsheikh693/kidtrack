import '../../../index/index_main.dart';

class AcademicTopicParentService {
  final BaseService<AcademicTopicModel> _service =
      Get.find<BaseService<AcademicTopicModel>>(tag: 'academicTopics');

  Future<void> getAll({
    required Function(List<AcademicTopicModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }
}
