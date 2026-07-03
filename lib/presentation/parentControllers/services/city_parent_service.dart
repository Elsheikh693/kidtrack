import '../../../index/index_main.dart';

/// Thin wrapper over the global `cities` CRUD service. Used by the SuperAdmin
/// cities screen, the manager nursery-profile city picker, and the pre-login
/// Discovery city filter.
class CityParentService {
  final BaseService<CityModel> _service =
      Get.find<BaseService<CityModel>>(tag: 'cities');

  Future<void> getAll({
    required Function(List<CityModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> save({
    required CityModel item,
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
