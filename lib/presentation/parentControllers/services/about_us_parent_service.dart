import '../../../index/index_main.dart';

class AboutUsParentService {
  final BaseService<AboutUsModel> _service =
      Get.find<BaseService<AboutUsModel>>(tag: 'aboutUs');

  Future<void> getAll({
    required Function(List<AboutUsModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> save({
    required AboutUsModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }
}
