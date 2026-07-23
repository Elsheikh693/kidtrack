import '../../../index/index_main.dart';

/// Read access to the withdrawal log (`platform/{nid}/withdrawals`). Entries are
/// written server-side by the `withdrawChild` Cloud Function; the app only reads
/// them to show the monthly "withdrawn" count and its detail list.
class WithdrawalParentService {
  final BaseService<WithdrawalLogModel> _service =
      Get.find<BaseService<WithdrawalLogModel>>(tag: 'withdrawals');

  Future<void> getAll({
    required Function(List<WithdrawalLogModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }
}
