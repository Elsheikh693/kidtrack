import '../../../../../../index/index_main.dart';

/// Parent Engagement report — how much guardians actually use the app, from the
/// engagement telemetry seeded on every parent record (loginCount, activity &
/// feed views, last-active). Network-level: parents carry no branch, so this
/// aggregates the whole nursery. Fetches the parent roster once on open.
class OwnerEngagementController extends GetxController {
  late final GuardianParentService _parents;

  final RxBool isLoading = false.obs;
  final RxList<ParentModel> all = <ParentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _parents = Get.find<GuardianParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _fetch();
      all.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ParentModel>> _fetch() {
    final c = Completer<List<ParentModel>>();
    _parents.getAll(callBack: (list) {
      if (!c.isCompleted) c.complete(list.whereType<ParentModel>().toList());
    });
    return c.future;
  }

  int get total => all.length;
  int get activated =>
      all.where((p) => p.onboardingStatus == ParentOnboardingStatus.activated)
          .length;

  /// Invitation sent but never logged in — the follow-up list.
  int get pending =>
      all.where((p) => p.onboardingStatus == ParentOnboardingStatus.sent).length;

  int get activationPercent =>
      total == 0 ? 0 : ((activated / total) * 100).round();

  int get totalActivityViews =>
      all.fold(0, (s, p) => s + p.activityViews);
  int get totalFeedViews => all.fold(0, (s, p) => s + p.feedViews);

  /// Most-engaged parents first (activity + feed views), only those who opened
  /// the app at least once.
  List<ParentModel> get leaderboard {
    final active = all.where((p) => p.loginCount > 0).toList()
      ..sort((a, b) => (b.activityViews + b.feedViews)
          .compareTo(a.activityViews + a.feedViews));
    return active.take(10).toList();
  }
}
