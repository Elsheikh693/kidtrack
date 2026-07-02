import '../../../../index/index_main.dart';

/// Read-only view of the nursery's parent ratings, shared by owner and manager
/// (both are scoped to the same `platform/{nurseryId}/feedback`). Backed by the
/// same service parents submit through.
class NurseryFeedbackListController extends GetxController {
  final NurseryFeedbackParentService _service =
      Get.find<NurseryFeedbackParentService>();

  final RxList<NurseryFeedbackModel> items = <NurseryFeedbackModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<NurseryFeedbackModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      },
    );
    isLoading.value = false;
  }

  int get totalCount => items.length;

  double get averageRating {
    if (items.isEmpty) return 0;
    final sum = items.fold<int>(0, (s, f) => s + f.rating);
    return sum / items.length;
  }

  /// Count of ratings for each star value, indexed 1..5 (index 0 unused).
  List<int> get distribution {
    final counts = List<int>.filled(6, 0);
    for (final f in items) {
      if (f.rating >= 1 && f.rating <= 5) counts[f.rating]++;
    }
    return counts;
  }
}
