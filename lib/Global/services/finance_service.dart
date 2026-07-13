import '../../index/index_main.dart';

class FinanceService {
  final _invoiceService = Get.find<BaseService<InvoiceModel>>(tag: 'invoices');
  final _paymentService = Get.find<BaseService<PaymentModel>>(tag: 'payments');

  /// Records a payment of [amount] against [invoice]. Supports partial
  /// collection: the amount is added to the invoice's running [paidAmount] and
  /// the status becomes 'paid' once fully covered, otherwise 'partial'. A
  /// [PaymentModel] is written for the actual amount collected (not the total).
  Future<bool> recordPayment({
    required InvoiceModel invoice,
    required double amount,
    required String paymentMethod,
    String? receivedByName,
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

    return paymentOk;
  }

  /// Settles the whole remaining balance of [invoice] in one shot (the "collect
  /// the rest" / mark-paid action). No-op if already fully paid.
  Future<bool> markAsPaid({
    required InvoiceModel invoice,
    required String paymentMethod,
    String? receivedByName,
  }) async {
    if (invoice.isFullyPaid) return true;
    return recordPayment(
      invoice: invoice,
      amount: invoice.remaining,
      paymentMethod: paymentMethod,
      receivedByName: receivedByName,
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
