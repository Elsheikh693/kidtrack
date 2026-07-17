import '../../../index/index_main.dart';
import 'tutorial_progress_store.dart';
import 'widgets/tutorial_complete_dialog.dart';

/// Drives the role-based "Learn the App" stepper. Loads the SuperAdmin's
/// tutorial catalogue for the current effective role, tracks which steps have
/// been finished (persisted locally), and celebrates once every step is done.
class AppTutorialController extends GetxController {
  late final TutorialVideoParentService _service;

  final videos = <TutorialVideoModel>[].obs;
  final watched = <String>{}.obs;
  final isLoading = true.obs;

  bool _celebrated = false;

  UserType get _role => SessionService().effectiveRole;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<TutorialVideoParentService>();
    watched.addAll(TutorialProgressStore.watched());
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        final visible = list
            .whereType<TutorialVideoModel>()
            .where((v) => v.isActive && v.visibleTo(_role))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        videos.assignAll(visible);
        isLoading.value = false;
        _celebrated = allDone; // don't re-congratulate an already-finished user
      },
    );
  }

  // ── Progress ────────────────────────────────────────────────────────────
  int get total => videos.length;

  int get doneCount =>
      videos.where((v) => watched.contains(v.key)).length;

  int get remaining => total - doneCount;

  double get progress => total == 0 ? 0 : doneCount / total;

  bool get allDone => total > 0 && doneCount >= total;

  /// The first not-yet-finished step — the one the user should watch next.
  int get currentIndex {
    for (var i = 0; i < videos.length; i++) {
      if (!watched.contains(videos[i].key)) return i;
    }
    return videos.length;
  }

  bool isWatched(TutorialVideoModel v) => watched.contains(v.key);

  /// A step is unlocked if it's already done or it is the current next step.
  bool isUnlocked(int index) =>
      watched.contains(videos[index].key) || index == currentIndex;

  // ── Actions ─────────────────────────────────────────────────────────────
  Future<void> openStep(int index) async {
    if (!isUnlocked(index)) {
      Loader.showInfo('tutorial_locked_hint'.tr);
      return;
    }
    await Get.toNamed(tutorialPlayerView, arguments: videos[index]);
    _refreshProgress();
  }

  void _refreshProgress() {
    watched
      ..clear()
      ..addAll(TutorialProgressStore.watched());
    if (allDone && !_celebrated) {
      _celebrated = true;
      showTutorialCompleteDialog();
    }
  }
}
