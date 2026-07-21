import '../../index/index_main.dart';

class FinanceService {
  final _invoiceService = Get.find<BaseService<InvoiceModel>>(tag: 'invoices');
  final _paymentService = Get.find<BaseService<PaymentModel>>(tag: 'payments');
  final _txService =
      Get.find<BaseService<FinancialTransactionModel>>(tag: 'financialTransactions');
  final _childService = Get.find<BaseService<ChildModel>>(tag: 'children');

  /// Records a payment of [amount] against [invoice]. Supports partial
  /// collection: the amount is added to the invoice's running [paidAmount] and
  /// the status becomes 'paid' once fully covered, otherwise 'partial'.
  ///
  /// THREE writes happen: the invoice is updated, a [PaymentModel] is written
  /// (invoice-settlement ledger), AND a [FinancialTransactionModel] is written
  /// (the revenue log every owner/finance report reads). Without the last one,
  /// invoice collections done here — manager/owner "mark as paid" and late-payer
  /// collect — would be invisible to owner revenue reports.
  ///
  /// [branchId] and [childName] let a caller that already holds the child skip
  /// the child lookup; omit them and the child is resolved from [invoice.childId].
  Future<bool> recordPayment({
    required InvoiceModel invoice,
    required double amount,
    required String paymentMethod,
    String? receivedByName,
    String? branchId,
    String? childName,
  }) async {
    if (amount <= 0) return false;

    final session = SessionService();
    final now = DateTime.now().millisecondsSinceEpoch;
    final name = receivedByName ?? session.currentUser?.displayName;

    final newPaid =
        (invoice.collectedAmount + amount).clamp(0, invoice.totalAmount).toDouble();
    final fullyPaid = newPaid >= invoice.totalAmount - 0.5;

    final updated = invoice.copyWith(
      paidAmount: newPaid,
      status: fullyPaid ? 'paid' : 'partial',
      paidAt: now,
      paidBy: name,
      paymentMethod: paymentMethod,
      updatedAt: now,
    );

    bool invoiceOk = false;
    await _invoiceService.updateData(
      item: updated,
      toJson: (m) => m.toJson(),
      id: invoice.key ?? '',
      voidCallBack: (status) => invoiceOk = status == ResponseStatus.success,
    );

    if (!invoiceOk) return false;

    final payment = PaymentModel(
      nurseryId: invoice.nurseryId,
      invoiceId: invoice.key ?? '',
      childId: invoice.childId,
      parentId: invoice.parentId,
      amount: amount,
      method: paymentMethod,
      receivedBy: name,
      paidAt: now,
    );

    bool paymentOk = false;
    await _paymentService.addData(
      item: payment,
      toJson: (m) => m.toJson(),
      id: '',
      voidCallBack: (status) => paymentOk = status == ResponseStatus.success,
    );

    await _recordRevenue(
      invoice: invoice,
      amount: amount,
      method: paymentMethod,
      collectedByName: name,
      collectedBy: session.userId,
      branchId: branchId,
      childName: childName,
      at: now,
    );

    return paymentOk;
  }

  /// Writes the revenue-log [FinancialTransactionModel] for a collection so the
  /// owner/finance dashboards (which read `financialTransactions`) include it.
  /// Resolves the child's branch/name when the caller didn't supply them.
  Future<void> _recordRevenue({
    required InvoiceModel invoice,
    required double amount,
    required String method,
    required String? collectedByName,
    required String? collectedBy,
    required String? branchId,
    required String? childName,
    required int at,
  }) async {
    var branch = branchId;
    var cName = childName;
    if (branch == null || branch.isEmpty || cName == null || cName.isEmpty) {
      await _childService.getData(
        data: {},
        voidCallBack: (list) {
          for (final c in list.whereType<ChildModel>()) {
            if (c.key == invoice.childId) {
              branch = (branch == null || branch!.isEmpty) ? c.branchId : branch;
              cName = (cName == null || cName!.isEmpty) ? c.fullName : cName;
              break;
            }
          }
        },
      );
    }

    final tx = FinancialTransactionModel(
      key: const Uuid().v4(),
      nurseryId: invoice.nurseryId,
      branchId: branch ?? '',
      childId: invoice.childId,
      childName: cName ?? '',
      categoryId: invoice.categoryId ?? invoice.packageId ?? '',
      categoryName: invoice.categoryName ??
          (invoice.title?.isNotEmpty == true
              ? invoice.title!
              : 'collection_fees'.tr),
      amount: amount,
      method: method,
      date: at,
      collectedBy: collectedBy,
      collectedByName: collectedByName,
    );
    await _txService.addData(
      item: tx,
      toJson: (m) => m.toJson(),
      id: '',
      voidCallBack: (_) {},
    );
  }

  /// Settles the whole remaining balance of [invoice] in one shot (the "collect
  /// the rest" / mark-paid action). No-op if already fully paid.
  Future<bool> markAsPaid({
    required InvoiceModel invoice,
    required String paymentMethod,
    String? receivedByName,
    String? branchId,
    String? childName,
  }) async {
    if (invoice.isFullyPaid) return true;
    return recordPayment(
      invoice: invoice,
      amount: invoice.remaining,
      paymentMethod: paymentMethod,
      receivedByName: receivedByName,
      branchId: branchId,
      childName: childName,
    );
  }

  Future<List<InvoiceModel>> getChildInvoices(String childId) async {
    final List<InvoiceModel> result = [];
    await _invoiceService.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list.whereType<InvoiceModel>().where((i) => i.childId == childId),
        );
      },
    );
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }
}
