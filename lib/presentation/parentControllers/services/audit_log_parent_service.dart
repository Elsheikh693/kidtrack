import '../../../index/index_main.dart';

class AuditLogParentService {
  final BaseService<AuditLogModel> _service =
      Get.find<BaseService<AuditLogModel>>(tag: 'auditLogs');

  Future<void> getAll({required Function(List<AuditLogModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required AuditLogModel item,
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
