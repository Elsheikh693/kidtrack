import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_dashboard_data.dart';

/// Executive Brief + Insights report — the daily summary plus the full
/// decision-oriented feed (problems and wins) the dashboard only teases. Pure
/// read of the shared bundle's [OwnerDashboardData] for the current scope.
class OwnerInsightsController extends GetxController {
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

  OwnerDashboardData get data => _analytics.dashboardData(_scope.scope.value);

  // ── PDF export data (pure records — no UI) ───────────────────────────────
  String get scopeLabel => _scope.currentLabel;

  List<({String label, String value})> get pdfKpis {
    final d = data;
    return [
      (label: 'owner_report_ins_critical'.tr, value: '${d.criticalCount}'),
      (label: 'owner_report_insights_priorities'.tr, value: '${d.problems.length}'),
      (label: 'owner_report_insights_wins'.tr, value: '${d.wins.length}'),
    ];
  }

  List<({String heading, List<({String label, String value})> rows})>
      get pdfSections {
    final d = data;
    return [
      if (d.problems.isNotEmpty)
        (
          heading: 'owner_report_insights_priorities'.tr,
          rows: [
            for (final p in d.problems) (label: p.title, value: p.impact),
          ],
        ),
      if (d.wins.isNotEmpty)
        (
          heading: 'owner_report_insights_wins'.tr,
          rows: [
            for (final w in d.wins) (label: w.title, value: w.impact),
          ],
        ),
    ];
  }
}
