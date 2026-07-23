import '../../../../index/index_main.dart';
import 'widgets/kidtrack_campaign_sheet.dart';

class KidtrackCampaignsController extends GetxController {
  late final KidtrackCampaignService _service;

  final RxList<KidtrackFeedbackCampaignModel> items =
      <KidtrackFeedbackCampaignModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<KidtrackCampaignService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    items.value = await _service.getAll();
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(KidtrackFeedbackCampaignModel item) => _openSheet(item);

  void _openSheet(KidtrackFeedbackCampaignModel? item) {
    Get.bottomSheet(
      KidtrackCampaignSheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> toggleEnabled(KidtrackFeedbackCampaignModel item) async {
    final id = item.key ?? '';
    if (id.isEmpty) return;
    Loader.show();
    try {
      await _service.setEnabled(id, !item.enabled);
      Loader.dismiss();
      Loader.showSuccess('sa_feedback_updated'.tr);
      await loadData();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }

  Future<void> delete(KidtrackFeedbackCampaignModel item) async {
    final id = item.key ?? '';
    if (id.isEmpty) return;
    Loader.show();
    try {
      await _service.delete(id);
      Loader.dismiss();
      Loader.showSuccess('sa_feedback_deleted'.tr);
      await loadData();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }
}
