import '../../../index/index_main.dart';

class SubjectParentService {
  final BaseService<SubjectModel> _service =
      Get.find<BaseService<SubjectModel>>(tag: 'subjects');

  /// [limit] caps the server-side result so existence probes fetch one row
  /// instead of the whole list.
  Future<void> getAll({
    required Function(List<SubjectModel?>) callBack,
    int? limit,
  }) async {
    await _service.getData(
      data: limit == null ? const {} : FirebaseFilter.firstN(limit),
      voidCallBack: callBack,
    );
  }

  Future<void> add({
    required SubjectModel item,
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
    required SubjectModel item,
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
