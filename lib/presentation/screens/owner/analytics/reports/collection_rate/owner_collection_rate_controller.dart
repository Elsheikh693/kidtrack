import '../../../../../../index/index_main.dart';
import '../../services/owner_finance_data_service.dart';

/// Real Collection Rate — this month's BILLED (sum of invoice totals due this
/// month) vs COLLECTED against those same invoices, so the rate reflects
/// enrollment × price, not a cash-log tautology.
class OwnerCollectionRateController extends GetxController {
  late final OwnerFinanceDataService _data;
  late final OwnerScopeService _scope;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<OwnerFinanceDataService>();
    _scope = Get.find<OwnerScopeService>();
    _data.ensureLoaded();
  }

  RxBool get firstLoading => _data.isFirstLoading;
  Future<void> reload() => _data.refresh();

  OwnerScope get _s => _scope.scope.value;
  DateTime get _month {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  List<InvoiceModel> get _monthInvoices => _data
      .invoicesFor(_s)
      .where((i) =>
          i.status != 'cancelled' &&
          OwnerFinanceDataService.inMonth(i.dueDate, _month))
      .toList();

  double get expected => _monthInvoices.fold(0.0, (s, i) => s + i.totalAmount);
  double get collected =>
      _monthInvoices.fold(0.0, (s, i) => s + i.collectedAmount);
  double get outstanding {
    final r = expected - collected;
    return r < 0 ? 0 : r;
  }

  int get ratePercent =>
      expected <= 0 ? 0 : ((collected / expected) * 100).round();

  int get invoiceCount => _monthInvoices.length;
  int get fullyPaidCount => _monthInvoices.where((i) => i.isFullyPaid).length;
  int get partialCount => _monthInvoices.where((i) => i.isPartiallyPaid).length;
  int get unpaidCount =>
      _monthInvoices.where((i) => i.collectedAmount <= 0.5).length;
}
