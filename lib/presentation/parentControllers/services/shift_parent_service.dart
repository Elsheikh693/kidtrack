import '../../../index/index_main.dart';

class ShiftParentService {
  final BaseService<ShiftModel> _service =
      Get.find<BaseService<ShiftModel>>(tag: 'shifts');

  Future<void> getAll({
    required Function(List<ShiftModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Active shifts only, ordered for display (sortOrder then start time).
  Future<List<ShiftModel>> getActive() async {
    final result = <ShiftModel>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list.whereType<ShiftModel>().where((s) => s.isActive),
        );
      },
    );
    result.sort((a, b) {
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.startMinutes.compareTo(b.startMinutes);
    });
    return result;
  }

  Future<void> add({
    required ShiftModel item,
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
    required ShiftModel item,
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
