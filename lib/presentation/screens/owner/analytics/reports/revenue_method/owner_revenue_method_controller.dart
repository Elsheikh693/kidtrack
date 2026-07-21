import '../../../../../../index/index_main.dart';
import '../../services/owner_finance_data_service.dart';

/// One payment-method bucket of this month's collections.
class MethodRevenue {
  final String method; // 'cash' | 'instapay' | 'wallet' | ''
  final double amount;
  const MethodRevenue(this.method, this.amount);
}

/// Revenue by Payment Method — how this month's collected money splits across
/// cash / InstaPay / e-wallet, read from the [FinancialTransactionModel.method]
/// stamped at collection time.
class OwnerRevenueMethodController extends GetxController {
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

  List<FinancialTransactionModel> get _monthTxns => _data
      .collectionsFor(_s)
      .where((t) => OwnerFinanceDataService.inMonth(t.date, _month))
      .toList();

  double get total => _monthTxns.fold(0.0, (s, t) => s + t.amount);

  /// Buckets sorted by amount desc. An empty method folds into the 'other' key.
  List<MethodRevenue> get slices {
    final by = <String, double>{};
    for (final t in _monthTxns) {
      final k = t.method.isEmpty ? 'other' : t.method;
      by[k] = (by[k] ?? 0) + t.amount;
    }
    final list = by.entries.map((e) => MethodRevenue(e.key, e.value)).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  int percentOf(double amount) =>
      total <= 0 ? 0 : ((amount / total) * 100).round();

  /// Localised label for a method key.
  String labelFor(String method) => method == 'other'
      ? 'owner_report_method_other'.tr
      : 'payment_method_$method'.tr;
}
