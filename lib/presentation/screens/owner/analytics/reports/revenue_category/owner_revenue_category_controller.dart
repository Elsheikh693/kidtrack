import '../../../../../../index/index_main.dart';
import '../../services/owner_finance_data_service.dart';

/// One fee-category / package bucket of this month's collections.
class OwnerCategoryRevenue {
  final String name;
  final double amount;
  const OwnerCategoryRevenue(this.name, this.amount);
}

/// Revenue by Package / Category — which fee categories (المصروفات الشهريه،
/// اشتراك باص، كتب…) brought the most money this month, from the snapshotted
/// [FinancialTransactionModel.categoryName].
class OwnerRevenueCategoryController extends GetxController {
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

  /// Categories ranked by revenue; blank names fold into an "uncategorised" row.
  List<OwnerCategoryRevenue> get categories {
    final by = <String, double>{};
    for (final t in _monthTxns) {
      final name = t.categoryName.trim().isEmpty
          ? 'owner_report_category_none'.tr
          : t.categoryName.trim();
      by[name] = (by[name] ?? 0) + t.amount;
    }
    final list = by.entries.map((e) => OwnerCategoryRevenue(e.key, e.value)).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  int percentOf(double amount) =>
      total <= 0 ? 0 : ((amount / total) * 100).round();
}
