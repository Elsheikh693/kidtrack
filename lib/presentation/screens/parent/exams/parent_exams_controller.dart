import '../../../../index/index_main.dart';

/// Loads the active child's written-exam results for the parent-facing exams
/// screen (reached from the Link Book). Also fetches the nursery name + logo so
/// the celebratory detail can produce a branded, shareable image.
class ParentExamsController extends GetxController {
  late final ExamResultParentService _resultService;
  late final NurseryParentService _nurseryService;

  final results = <ExamResultModel>[].obs;
  final isLoading = false.obs;

  final nurseryName = ''.obs;
  final nurseryLogo = RxnString();

  String childId = '';
  String childName = '';

  @override
  void onInit() {
    super.onInit();
    final active = Get.find<ActiveChildService>();
    childId = active.childId.value;
    childName = active.childName.value;

    _resultService = Get.find<ExamResultParentService>();
    _nurseryService = Get.find<NurseryParentService>();

    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _resultService.getForChild(childId);
      results.assignAll(list);
      await _loadNursery();
      // Opening the list clears the home "new exams" badge.
      await ParentDashboardController.markExamsSeen(childId);
    } catch (_) {
      // Leave the (possibly empty) list — the empty state renders.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadNursery() async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;
    final nursery = await _nurseryService.getOne(nurseryId);
    if (nursery == null) return;
    nurseryName.value = nursery.name;
    nurseryLogo.value = nursery.logo;
  }
}
