import '../../../index/index_main.dart';

class ClassroomPostParentService {
  final BaseService<ClassroomPostModel> _service =
      Get.find<BaseService<ClassroomPostModel>>(tag: 'classroomPosts');

  Future<void> getAll({required Function(List<ClassroomPostModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ClassroomPostModel item,
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
    required ClassroomPostModel item,
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
