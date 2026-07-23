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

  /// Fixed demo activation codes, keyed by role, surfaced inline on each role's
  /// tutorial card so a tester can copy that role's code, sign out, and log back
  /// in as the role to try the app hands-on.
  static const Map<String, String> _demoCodes = {
    'owner': 'CZX2-8Z3A',
    'manager': '3GB9-Q2K7',
    'teacher': 'P4DV-W6T6',
    'reception': '7Y36-FY5S',
    'parent': 'Q88V-446F',
  };

  /// Best-effort match of a tutorial video (by title) to the role it explains,
  /// returning that role's demo code — or null when the video isn't a role
  /// walkthrough (e.g. the nursery-profile intro or the owner video).
  String? demoCodeFor(TutorialVideoModel v) {
    final t = v.title;
    final lower = t.toLowerCase();
    if (t.contains('استقبال') || lower.contains('reception')) {
      return _demoCodes['reception'];
    }
    if (t.contains('معلم') || t.contains('معلّم') || lower.contains('teacher')) {
      return _demoCodes['teacher'];
    }
    if (t.contains('مدير') || lower.contains('manager')) {
      return _demoCodes['manager'];
    }
    if (t.contains('ولي') ||
        lower.contains('parent') ||
        lower.contains('guardian')) {
      return _demoCodes['parent'];
    }
    if (t.contains('صاحب') || t.contains('مالك') || lower.contains('owner')) {
      return _demoCodes['owner'];
    }
    return null;
  }

  void copyDemoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Loader.showSuccess('activation_code_copied'.tr);
  }

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
