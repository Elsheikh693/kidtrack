import '../../index/index_main.dart';

class FinanceService {
  final _invoiceService = Get.find<BaseService<InvoiceModel>>(tag: 'invoices');
  final _paymentService = Get.find<BaseService<PaymentModel>>(tag: 'payments');

  Future<bool> markAsPaid({
    required InvoiceModel invoice,
    required String paymentMethod,
    String? receivedByName,
  }) async {
    final session = SessionService();
    final now = DateTime.now().millisecondsSinceEpoch;
    final name = receivedByName ?? session.currentUser?.displayName;

    final updated = invoice.copyWith(
      status: 'paid',
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
      amount: invoice.totalAmount,
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
