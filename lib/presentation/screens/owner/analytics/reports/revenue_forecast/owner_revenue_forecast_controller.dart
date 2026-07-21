import '../../../../../../index/index_main.dart';
import '../../services/owner_finance_data_service.dart';

/// One package's contribution to the forecast — subscriber count × monthly due.
class PackageForecast {
  final String name;
  final int subscribers;
  final double amount;
  const PackageForecast(this.name, this.subscribers, this.amount);
}

/// Revenue Forecast — next month's EXPECTED fees, derived from currently active
/// children × their active packages' monthly-equivalent price (`monthlyDue`) —
/// the same basis [MonthlyInvoiceService] bills on. A forward run-rate, not a
/// collection.
class OwnerRevenueForecastController extends GetxController {
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

  List<ChildModel> get _children => _data.activeChildrenFor(_s);
  Map<String, PackageModel> get _packages => _data.packagesById;

  List<PackageModel> _childPackages(ChildModel c) => c.packageIds
      .map((id) => _packages[id])
      .whereType<PackageModel>()
      .where((p) => p.isActive)
      .toList();

  /// Total forecasted monthly fees across active children in scope.
  double get forecast => _children.fold(
      0.0, (s, c) => s + _childPackages(c).fold(0.0, (a, p) => a + p.monthlyDue));

  int get childrenCount => _children.length;

  /// Active children who carry at least one active package (the billable ones).
  int get billableCount =>
      _children.where((c) => _childPackages(c).isNotEmpty).length;

  double get avgFee => billableCount == 0 ? 0 : forecast / billableCount;

  /// Per-package contribution, ranked by amount.
  List<PackageForecast> get byPackage {
    final subs = <String, int>{};
    final amt = <String, double>{};
    final name = <String, String>{};
    for (final c in _children) {
      for (final p in _childPackages(c)) {
        final id = p.key ?? p.name;
        subs[id] = (subs[id] ?? 0) + 1;
        amt[id] = (amt[id] ?? 0) + p.monthlyDue;
        name[id] = p.name;
      }
    }
    final list = amt.entries
        .map((e) =>
            PackageForecast(name[e.key] ?? '', subs[e.key] ?? 0, e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}
