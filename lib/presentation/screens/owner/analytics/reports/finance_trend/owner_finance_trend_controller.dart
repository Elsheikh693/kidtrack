import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_dashboard_data.dart';
import '../../../executive/models/monthly_finance_point.dart';
import '../../../executive/models/owner_insight_item.dart';

/// 12-month finance trend report. Pure read of the shared bundle's
/// [OwnerDashboardData.financeTrend] (collected vs expenses per month) for the
/// current scope. Holds only a selected-month index so the chart and the
/// history list stay in sync when either is tapped.
class OwnerFinanceTrendController extends GetxController {
  late final OwnerAnalyticsService _analytics;
  late final OwnerScopeService _scope;

  /// Which month is highlighted in the chart/list (defaults to newest).
  final RxInt selected = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _analytics = Get.find<OwnerAnalyticsService>();
    _scope = Get.find<OwnerScopeService>();
    _analytics.ensureLoaded();
  }

  RxBool get firstLoading => _analytics.isFirstLoading;
  Future<void> reload() => _analytics.refresh();

  OwnerDashboardData get data => _analytics.dashboardData(_scope.scope.value);
  List<MonthlyFinancePoint> get trend => data.financeTrend;

  /// Newest-first selection defaults to the last point when nothing is picked.
  int get selectedIndex =>
      selected.value < 0 ? (trend.isEmpty ? 0 : trend.length - 1) : selected.value;

  void selectMonth(int index) => selected.value = index;

  double get totalCollected =>
      trend.fold(0.0, (s, p) => s + p.collected);
  double get totalExpenses => trend.fold(0.0, (s, p) => s + p.expenses);
  double get totalProfit => totalCollected - totalExpenses;

  // ── PDF export data (pure records — no UI) ───────────────────────────────
  String get scopeLabel => _scope.currentLabel;
  String _money(double v) => '${formatMoney(v)} ${'owner_currency'.tr}';

  List<({String label, String value})> get pdfKpis => [
        (label: 'owner_report_ft_collected'.tr, value: _money(totalCollected)),
        (label: 'owner_report_ft_expenses'.tr, value: _money(totalExpenses)),
        (label: 'owner_report_ft_profit'.tr, value: _money(totalProfit)),
      ];

  List<({String heading, List<({String label, String value})> rows})>
      get pdfSections => [
            (
              heading: 'owner_report_ft_history'.tr,
              rows: [
                for (final p in trend)
                  (
                    label: '${p.month}/${p.year}',
                    value: '${_money(p.collected)} · ${_money(p.profit)}',
                  ),
              ],
            ),
          ];
}
