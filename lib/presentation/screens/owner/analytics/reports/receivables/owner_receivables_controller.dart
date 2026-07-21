import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_metrics.dart';
import '../../../executive/models/branch_metrics.dart';

/// Accounts-Receivable report — the CURRENT unpaid picture (not period-bounded):
/// total outstanding, overdue invoices/amount, and families overdue >60 days.
/// Reads the raw scope metrics for the 60-day fields the snapshots omit, plus a
/// per-branch overdue breakdown on the network view.
class OwnerReceivablesController extends GetxController {
  late final OwnerAnalyticsService _analytics;
  late final OwnerScopeService _scope;

  @override
  void onInit() {
    super.onInit();
    _analytics = Get.find<OwnerAnalyticsService>();
    _scope = Get.find<OwnerScopeService>();
    _analytics.ensureLoaded();
  }

  RxBool get firstLoading => _analytics.isFirstLoading;
  Future<void> reload() => _analytics.refresh();

  /// Null until the bundle lands — the view shows a skeleton meanwhile.
  OwnerMetrics? get metrics => _analytics.scopeMetrics(_scope.scope.value);

  bool get showBranches =>
      _scope.scope.value.isNetwork && _analytics.branches.length > 1;

  /// Per-branch rows, worst overdue amount first.
  List<BranchMetricsEntry> get branches {
    final list =
        _analytics.branches.where((b) => b.current.overdueAmount > 0).toList();
    list.sort(
        (a, b) => b.current.overdueAmount.compareTo(a.current.overdueAmount));
    return list;
  }

  double get maxBranchOverdue =>
      branches.isEmpty ? 1 : branches.first.current.overdueAmount;
}
