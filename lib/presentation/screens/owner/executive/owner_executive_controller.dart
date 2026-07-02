import '../../../../../index/index_main.dart';
import 'models/owner_dashboard_data.dart';
import 'services/owner_metrics_service.dart';
import 'services/owner_metrics_cache.dart';
import 'services/owner_insight_service.dart';

/// Drives the owner's executive dashboard.
///
/// Loading strategy (cache-first, never blocking):
///   open → paint cached metrics instantly → refresh from Firebase in the
///   background → update UI → persist the new snapshot.
/// The shimmer only shows on a true cold start (no cache); every later open or
/// pull-to-refresh keeps the last data on screen and updates in place.
///
/// Scope is re-sliced LOCALLY: the bundle holds every branch + the network
/// aggregate, so switching scope just rebuilds the dashboard from the cached
/// bundle — no refetch.
class OwnerExecutiveController extends GetxController {
  final OwnerMetricsService _metrics = OwnerMetricsService();
  final OwnerMetricsCache _cache = OwnerMetricsCache();
  final OwnerInsightService _insights = OwnerInsightService();
  final OwnerScopeService _scopeService = Get.find<OwnerScopeService>();

  final Rxn<OwnerDashboardData> data = Rxn<OwnerDashboardData>();

  /// Cold start with nothing cached — the only time the shimmer shows.
  final RxBool isFirstLoading = false.obs;

  /// A background sync is in flight while data is already on screen.
  final RxBool isRefreshing = false.obs;

  /// Last raw bundle (network + every branch). Scope switches re-slice this.
  OwnerMetricsBundle? _bundle;

  /// branchId → its goals/weights. Empty map → every branch uses defaults.
  Map<String, BranchTargetModel> _targets = const {};

  Worker? _scopeWorker;

  @override
  void onInit() {
    super.onInit();
    _scopeWorker = ever(_scopeService.scope, (_) => _rebuild());
    _boot();
  }

  @override
  void onClose() {
    _scopeWorker?.dispose();
    super.onClose();
  }

  Future<void> _boot() async {
    _scopeService.loadBranches();
    final cached = _cache.read();
    if (cached != null) {
      _bundle = cached;
      _rebuild();
    } else {
      isFirstLoading.value = true;
    }
    await _refresh();
  }

  /// Pull-to-refresh entry point. Keeps current data visible.
  Future<void> reload() => _refresh();

  Future<void> _refresh() async {
    isRefreshing.value = true;
    try {
      final results = await Future.wait([
        _metrics.loadBundle(),
        _fetchTargets(),
      ]);
      _bundle = results[0] as OwnerMetricsBundle;
      _targets = results[1] as Map<String, BranchTargetModel>;
      _rebuild();
      await _cache.write(_bundle!);
    } finally {
      isFirstLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Recomputes the dashboard from the cached bundle for the CURRENT scope.
  /// Cheap + pure — safe to call on every scope switch.
  void _rebuild() {
    final bundle = _bundle;
    if (bundle == null) return;
    final scope = _scopeService.scope.value;
    data.value = _insights.build(
      bundle,
      isNetwork: scope.isNetwork,
      branchId: scope.branchId,
      scopeLabel: _scopeService.currentLabel,
      targets: _targets,
    );
  }

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
}
