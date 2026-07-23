import '../../../../../index/index_main.dart';
import '../../executive/models/owner_dashboard_data.dart';
import '../../executive/models/owner_metrics.dart';
import '../../executive/models/branch_metrics.dart';
import '../../executive/services/owner_metrics_service.dart';
import '../../executive/services/owner_metrics_cache.dart';
import '../../executive/services/owner_insight_service.dart';

/// THE shared data layer behind the owner Analytics Center.
///
/// The executive engine is compute-once, read-many: [OwnerMetricsService]
/// fetches ~11 collections ONCE into an [OwnerMetricsBundle], and
/// [OwnerInsightService] folds it into a per-scope [OwnerDashboardData]. Every
/// analytics report is just a View over that result.
///
/// This service loads the bundle ONCE per session and hands every report a
/// pure, cheap [dashboardData] slice for the current scope — so opening five
/// reports never triggers five Firebase fetches. Registered permanent (mirrors
/// [OwnerScopeService]); resolving [BaseService]/[WithdrawalParentService]
/// directly here follows the ParentService "aggregate multiple models"
/// allowance — keep all such access inside this service.
class OwnerAnalyticsService extends GetxService {
  final OwnerMetricsService _metrics = OwnerMetricsService();
  final OwnerMetricsCache _cache = OwnerMetricsCache();
  final OwnerInsightService _insights = OwnerInsightService();

  /// The raw computed picture (network + every branch). Null until first load.
  final Rxn<OwnerMetricsBundle> bundle = Rxn<OwnerMetricsBundle>();

  /// Cold start with nothing cached — the only time reports show a shimmer.
  final RxBool isFirstLoading = false.obs;

  /// A background sync is in flight while data is already on screen.
  final RxBool isRefreshing = false.obs;

  /// branchId → its goals/weights. Empty → every branch uses defaults.
  Map<String, BranchTargetModel> _targets = const {};

  /// Raw withdrawal log (every branch). Reactive so churn reports repaint when
  /// it lands (it isn't part of the cached bundle). Sliced per scope/month.
  final RxList<WithdrawalLogModel> _allWithdrawals = <WithdrawalLogModel>[].obs;

  /// Cache-first warm-up. Paints the last-known bundle instantly, then refreshes
  /// in the background. A NO-OP once a bundle is already in memory — this is what
  /// stops every report re-fetching when the owner opens several in a row.
  Future<void> ensureLoaded() async {
    if (bundle.value != null) return;
    final cached = _cache.read();
    if (cached != null) {
      bundle.value = cached;
    } else {
      isFirstLoading.value = true;
    }
    await refresh();
  }

  /// Re-fetch everything from Firebase, keeping current data visible.
  Future<void> refresh() async {
    isRefreshing.value = true;
    try {
      final results = await Future.wait([
        _metrics.loadBundle(),
        _fetchTargets(),
        _fetchWithdrawals(),
      ]);
      bundle.value = results[0] as OwnerMetricsBundle;
      _targets = results[1] as Map<String, BranchTargetModel>;
      _allWithdrawals.assignAll(results[2] as List<WithdrawalLogModel>);
      await _cache.write(bundle.value!);
    } finally {
      isFirstLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// The display-ready dashboard for [scope]. Pure + cheap — safe to call on
  /// every scope switch; returns an empty shell until the first bundle lands.
  OwnerDashboardData dashboardData(OwnerScope scope) {
    final b = bundle.value;
    if (b == null) return OwnerDashboardData.empty();
    return _insights.build(
      b,
      isNetwork: scope.isNetwork,
      branchId: scope.branchId,
      scopeLabel: _scopeLabel(scope),
      targets: _targets,
    );
  }

  /// Per-branch metrics (network + direct costs). Empty until loaded.
  List<BranchMetricsEntry> get branches => bundle.value?.branches ?? const [];

  /// The raw current-period metrics for [scope] — used by reports that need
  /// fields the [OwnerDashboardData] snapshots don't surface (e.g. 60-day
  /// overdue families). Null until the bundle lands.
  OwnerMetrics? scopeMetrics(OwnerScope scope) {
    final b = bundle.value;
    if (b == null) return null;
    if (scope.isNetwork) return b.network.current;
    return b.branches
            .firstWhereOrNull((e) => e.branchId == scope.branchId)
            ?.current ??
        b.network.current;
  }

  /// Network-level overhead (expenses with no branch) this/last month.
  ({double current, double previous}) get overhead {
    final b = bundle.value;
    return (
      current: b?.overheadCurrent ?? 0,
      previous: b?.overheadPrevious ?? 0,
    );
  }

  /// This-month withdrawals for [scope] (all branches on the network view),
  /// newest first — the surviving churn log with each child's exit reason.
  List<WithdrawalLogModel> withdrawalsFor(OwnerScope scope, {DateTime? month}) {
    final anchor = month ?? DateTime.now();
    // Iterating the RxList reports a read, so this registers as a dependency
    // inside Obx and repaints when the withdrawal log lands.
    return _allWithdrawals
        .where((w) => scope.isNetwork || w.branchId == scope.branchId)
        .where((w) {
      final d = w.withdrawnDate;
      return d != null && d.year == anchor.year && d.month == anchor.month;
    }).toList()
      ..sort((a, b) => (b.withdrawnAt ?? 0).compareTo(a.withdrawnAt ?? 0));
  }

  String _scopeLabel(OwnerScope scope) =>
      scope.isNetwork ? 'owner_scope_all_branches'.tr : scope.branchName ?? '';

  Future<Map<String, BranchTargetModel>> _fetchTargets() {
    final completer = Completer<Map<String, BranchTargetModel>>();
    Get.find<BaseService<BranchTargetModel>>(tag: 'branchTargets').getData(
      data: {},
      voidCallBack: (list) {
        if (completer.isCompleted) return;
        completer.complete({
          for (final t in list.whereType<BranchTargetModel>())
            if (t.key != null) t.key!: t,
        });
      },
    );
    return completer.future;
  }

  Future<List<WithdrawalLogModel>> _fetchWithdrawals() {
    final completer = Completer<List<WithdrawalLogModel>>();
    Get.find<WithdrawalParentService>().getAll(
      callBack: (list) {
        if (completer.isCompleted) return;
        completer.complete(list.whereType<WithdrawalLogModel>().toList());
      },
    );
    return completer.future;
  }
}
