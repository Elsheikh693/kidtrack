import '../../../index/index_main.dart';

class TopicProgressParentService {
  final BaseService<TopicProgressModel> _service =
      Get.find<BaseService<TopicProgressModel>>(tag: 'topicProgress');

  Future<void> getAll({
    required Function(List<TopicProgressModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }
}
