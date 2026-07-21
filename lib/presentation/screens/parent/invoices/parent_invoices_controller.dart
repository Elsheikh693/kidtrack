import '../../../../index/index_main.dart';
import 'widgets/pay_invoice_view.dart';

/// Parent's finance screen for the active child: the outstanding invoices they
/// still owe (each payable by transferring to a nursery account + uploading a
/// screenshot) plus the read-only history of recorded collections.
///
/// History is built on [FinancialTransactionModel] via a Child→Transactions
/// read; outstanding invoices come from [InvoiceParentService] filtered to the
/// active child. The nursery's collection accounts are loaded once for the pay
/// sheet.
class ParentInvoicesController extends GetxController {
  final _service = Get.find<FinancialTransactionParentService>();
  final _accountService = Get.find<PaymentAccountParentService>();

  final RxList<FinancialTransactionModel> items =
      <FinancialTransactionModel>[].obs;

  /// Unpaid / partially-paid invoices for the active child.
  final RxList<InvoiceModel> outstanding = <InvoiceModel>[].obs;

  /// The nursery's collection accounts, shown on the pay sheet.
  final RxList<PaymentAccountModel> accounts = <PaymentAccountModel>[].obs;

  final RxBool isLoading = true.obs;

  String get _childId => Get.find<ActiveChildService>().childId.value;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _loadAccounts();
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) => loadData(),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  /// Total amount this child has paid across all recorded collections.
  double get totalPaid => items.fold(0, (total, t) => total + t.amount);

  /// Number of recorded payments.
  int get count => items.length;

  /// [showLoader] blanks the screen to the shimmer skeleton — true on first load
  /// and child-switch, false for silent refreshes (returning from the pay flow,
  /// pull-to-refresh) so the list doesn't flash a loader every time.
  Future<void> loadData({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    final childId = _childId;
    if (childId.isEmpty) {
      items.clear();
      outstanding.clear();
      isLoading.value = false;
      return;
    }
    // Fetch the collection history CONCURRENTLY with ensuring this month's fee
    // invoice exists — generateForChild returns the child's invoices, so we get
    // the outstanding list without a second round-trip.
    final txFuture = _service.getByChild(childId);
    final invoices = await MonthlyInvoiceService().generateForChild(childId);
    outstanding.value = invoices.where((i) => i.hasOutstanding).toList()
      ..sort((a, b) => (a.dueDate ?? a.createdAt ?? 0)
          .compareTo(b.dueDate ?? b.createdAt ?? 0));
    // Already sorted newest-first by the service.
    items.value = await txFuture;
    isLoading.value = false;
  }

  Future<void> _loadAccounts() async {
    await _accountService.getAll(
      callBack: (list) {
        accounts.value = list.whereType<PaymentAccountModel>().toList()
          ..sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
      },
    );
  }

  void openPay(InvoiceModel invoice) {
    Get.to(() => PayInvoiceView(invoice: invoice, accounts: accounts))
        ?.then((_) => loadData(showLoader: false));
  }

  void copyValue(String v) {
    Clipboard.setData(ClipboardData(text: v));
    Loader.showSuccess('pay_copied'.tr);
  }

  Future<void> openPaymentLink(String url) async {
    var n = url.trim();
    if (n.isEmpty) return;
    if (!n.startsWith('http')) n = 'https://$n';
    final uri = Uri.tryParse(n);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('pay_open_error'.tr);
    }
  }
}
