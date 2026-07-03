import '../../../index/index_main.dart';

class FinancialTransactionParentService {
  final BaseService<FinancialTransactionModel> _service =
      Get.find<BaseService<FinancialTransactionModel>>(
    tag: 'financialTransactions',
  );

  /// Whole-node read. Use for owner/manager reports that aggregate everything;
  /// prefer [getByBranch] / [getByChild] for scoped screens.
  Future<void> getAll({
    required Function(List<FinancialTransactionModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// One child's transactions, newest first — backs the parent payment history.
  ///
  /// MVP: filters client-side. Swap to a server-side `orderBy="childId"` query
  /// once the RTDB `.indexOn: ["childId","branchId"]` rule for
  /// `financialTransactions` is deployed (parents must NOT download the whole
  /// node in production).
  Future<List<FinancialTransactionModel>> getByChild(String childId) async {
    final result = <FinancialTransactionModel>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list
              .whereType<FinancialTransactionModel>()
              .where((t) => t.childId == childId),
        );
      },
    );
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// One branch's transactions — backs reception history + manager reports.
  Future<List<FinancialTransactionModel>> getByBranch(String branchId) async {
    final result = <FinancialTransactionModel>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list
              .whereType<FinancialTransactionModel>()
              .where((t) => t.branchId == branchId),
        );
      },
    );
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<void> add({
    required FinancialTransactionModel item,
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
    required FinancialTransactionModel item,
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
