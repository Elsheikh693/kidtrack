import '../../../index/index_main.dart';

/// Standard CRUD wrapper over the nursery's payment-receiving accounts
/// (`$_n/paymentAccounts`). Edited by the owner/manager, read by guardians on
/// the invoice-payment sheet.
class PaymentAccountParentService {
  final BaseService<PaymentAccountModel> _service =
      Get.find<BaseService<PaymentAccountModel>>(tag: 'paymentAccounts');

  Future<void> getAll({
    required Function(List<PaymentAccountModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required PaymentAccountModel item,
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
    required PaymentAccountModel item,
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
