import '../../../index/index_main.dart';

class FeeCategoryParentService {
  final BaseService<FeeCategoryModel> _service =
      Get.find<BaseService<FeeCategoryModel>>(tag: 'feeCategories');

  Future<void> getAll({
    required Function(List<FeeCategoryModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Active categories only, sorted for display (sortOrder then name).
  Future<List<FeeCategoryModel>> getActive() async {
    final result = <FeeCategoryModel>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list.whereType<FeeCategoryModel>().where((c) => c.isActive),
        );
      },
    );
    result.sort((a, b) {
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.name.compareTo(b.name);
    });
    return result;
  }

  Future<void> add({
    required FeeCategoryModel item,
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
    required FeeCategoryModel item,
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
