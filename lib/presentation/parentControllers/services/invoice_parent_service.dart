import '../../../index/index_main.dart';

class InvoiceParentService {
  final BaseService<InvoiceModel> _service =
      Get.find<BaseService<InvoiceModel>>(tag: 'invoices');

  Future<void> getAll({required Function(List<InvoiceModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required InvoiceModel item,
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
    required InvoiceModel item,
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
