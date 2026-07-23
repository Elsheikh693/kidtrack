import '../../../../../../index/index_main.dart';
import '../../../executive/models/branch_metrics.dart';
import '../../../executive/models/owner_insight_item.dart';

/// Branch P&L report — per-branch collected − direct expenses = direct profit,
/// ranked, plus the network overhead shown separately (only branch-direct costs
/// live on each branch, per the metrics design). Pure reads of the shared
/// bundle; nothing is re-fetched.
class OwnerBranchPnlController extends GetxController {
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

  bool get isNetwork => _scope.scope.value.isNetwork;

  /// Branches ranked by direct profit (best first).
  List<BranchMetricsEntry> get branches {
    final list = [..._analytics.branches];
    list.sort((a, b) => b.directProfit.compareTo(a.directProfit));
    return list;
  }

  /// Largest collected value among branches — the bar's 100% reference.
  double get maxCollected {
    final vals = _analytics.branches.map((b) => b.current.collected);
    final m = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a > b ? a : b);
    return m <= 0 ? 1 : m;
  }

  double get totalCollected =>
      _analytics.branches.fold(0.0, (s, b) => s + b.current.collected);
  double get totalExpenses =>
      _analytics.branches.fold(0.0, (s, b) => s + b.current.expenses);
  double get overhead => _analytics.overhead.current;

  /// Network net after direct costs AND overhead.
  double get netProfit => totalCollected - totalExpenses - overhead;

  // ── PDF export data (pure records — no UI) ───────────────────────────────
  String get scopeLabel => _scope.currentLabel;
  String _money(double v) => '${formatMoney(v)} ${'owner_currency'.tr}';

  List<({String label, String value})> get pdfKpis => [
        (label: 'owner_report_pnl_collected'.tr, value: _money(totalCollected)),
        (label: 'owner_report_pnl_expenses'.tr, value: _money(totalExpenses)),
        (label: 'owner_report_pnl_net'.tr, value: _money(netProfit)),
      ];

  List<({String heading, List<({String label, String value})> rows})>
      get pdfSections => [
            (
              heading: 'owner_report_pnl_by_branch'.tr,
              rows: [
                for (final b in branches)
                  (label: b.branchName, value: _money(b.directProfit)),
                (
                  label: 'owner_report_pnl_overhead'.tr,
                  value: _money(overhead)
                ),
              ],
            ),
          ];
}
