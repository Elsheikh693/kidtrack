import '../../../../index/index_main.dart';

/// Drives the Analytics Center hub. It owns no report logic — its only job is to
/// warm the shared [OwnerAnalyticsService] bundle once, so that when the owner
/// drills into any report the data is already in memory (no per-screen refetch).
class AnalyticsCenterController extends GetxController {
  late final OwnerAnalyticsService _analytics;

  @override
  void onInit() {
    super.onInit();
    _analytics = Get.find<OwnerAnalyticsService>();
    _analytics.ensureLoaded();
  }

  /// True only on a cold start with nothing cached — the hub stays interactive
  /// regardless, but reports can show a shimmer while this is true.
  RxBool get isLoading => _analytics.isFirstLoading;
}
