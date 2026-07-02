import '../../../index/index_main.dart';

class AnnouncementParentService {
  final BaseService<AnnouncementModel> _service =
      Get.find<BaseService<AnnouncementModel>>(tag: 'announcements');

  Future<void> getAll({required Function(List<AnnouncementModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required AnnouncementModel item,
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
    required AnnouncementModel item,
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
