import '../../../index/index_main.dart';

class ContactInfoParentService {
  final BaseService<ContactInfoModel> _service =
      Get.find<BaseService<ContactInfoModel>>(tag: 'contactInfo');

  Future<void> getAll({
    required Function(List<ContactInfoModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> save({
    required ContactInfoModel item,
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
