import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_dashboard_data.dart';

/// Occupancy report — active children vs capacity, free seats, and per-classroom
/// fill %. Pure read of the shared bundle's [GrowthSnapshot] for the current
/// scope. (No waiting-list figure: that data isn't captured by any live flow,
/// so we don't surface an empty number.)
class OwnerOccupancyController extends GetxController {
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

  GrowthSnapshot get growth =>
      _analytics.dashboardData(_scope.scope.value).growth;

  /// Rooms sorted fullest first, so the tightest capacity shows at the top.
  List<ClassroomOccupancyView> get rooms {
    final list = [...growth.classrooms];
    list.sort((a, b) => b.fillPercent.compareTo(a.fillPercent));
    return list;
  }
}
