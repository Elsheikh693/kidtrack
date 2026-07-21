import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_dashboard_data.dart';
import '../../../executive/models/branch_metrics.dart';

/// Collections report — this-period billing vs cash: expected (billed),
/// collected, outstanding and the collection rate, with a per-branch breakdown
/// on the network view. All pure reads of the shared bundle for the current
/// scope; the per-branch rows come straight off [BranchMetricsEntry.current].
class OwnerCollectionsController extends GetxController {
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
  FinanceSnapshot get finance => data.finance;

  /// Per-branch collection rows, best rate first — only meaningful across the
  /// whole network with more than one branch.
  bool get showBranches =>
      _scope.scope.value.isNetwork && _analytics.branches.length > 1;

  List<BranchMetricsEntry> get branches {
    final list = [..._analytics.branches];
    list.sort(
        (a, b) => b.current.collectionRate.compareTo(a.current.collectionRate));
    return list;
  }
}
