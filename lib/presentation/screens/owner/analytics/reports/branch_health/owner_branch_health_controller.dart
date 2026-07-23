import '../../../../../../index/index_main.dart';
import '../../../executive/models/branch_health.dart';

/// Branch Health Ranking report — branches ranked by the explainable 0–100
/// health score (occupancy + collections + teacher-activity + pending-tasks).
/// Pure read of the shared bundle's already-computed ranking; branches with no
/// real data yet are excluded so they aren't shown as "at risk".
class OwnerBranchHealthController extends GetxController {
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

  /// Ranked, best score first, only branches that have data to measure.
  List<BranchHealthScore> get ranking => _analytics
      .dashboardData(_scope.scope.value)
      .branchRanking
      .where((b) => b.hasData)
      .toList();

  int get emptyBranches => _analytics
      .dashboardData(_scope.scope.value)
      .branchRanking
      .where((b) => !b.hasData)
      .length;

  // ── PDF export data (pure records — no UI) ───────────────────────────────
  String get scopeLabel => _scope.currentLabel;

  List<({String label, String value})> get pdfKpis {
    final r = ranking;
    return [
      (label: 'owner_report_bh_branches'.tr, value: '${r.length}'),
      if (r.isNotEmpty)
        (label: 'owner_report_bh_top'.tr, value: '${r.first.scoreRounded}'),
    ];
  }

  List<({String heading, List<({String label, String value})> rows})>
      get pdfSections => [
            (
              heading: 'owner_report_branch_health_title'.tr,
              rows: [
                for (final b in ranking)
                  (
                    label: b.branchName,
                    value: '${b.scoreRounded} — ${b.bandKey.tr}',
                  ),
              ],
            ),
          ];
}
