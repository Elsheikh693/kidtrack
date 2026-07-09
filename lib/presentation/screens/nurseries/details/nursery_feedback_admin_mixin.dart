import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import 'widgets/campaign_picker_sheet.dart';

/// SuperAdmin control of a nursery's KidTrack app-rating campaign, mixed into
/// [NurseryDetailsController]: assign/disable the campaign, read live response
/// stats, push reminders to non-responders, and open the responses screen.
///
/// Writes the link directly to the global registry
/// (`platform/info/{nurseryId}/kidtrackFeedbackCampaignId`) because the campaign
/// id is a single field on the nursery record and disabling must null it (which
/// [NurseryModel.copyWith] can't express).
mixin NurseryFeedbackAdminMixin on GetxController {
  Rx<NurseryModel> get nursery;

  final RxList<KidtrackFeedbackCampaignModel> campaigns =
      <KidtrackFeedbackCampaignModel>[].obs;
  final Rxn<KidtrackFeedbackCampaignModel> currentCampaign =
      Rxn<KidtrackFeedbackCampaignModel>();
  final Rxn<KidtrackFeedbackStats> feedbackStats =
      Rxn<KidtrackFeedbackStats>();
  final RxBool loadingFeedback = true.obs;

  KidtrackCampaignService get _campaignService =>
      Get.find<KidtrackCampaignService>();
  KidtrackFeedbackService get _feedbackService =>
      Get.find<KidtrackFeedbackService>();

  Future<void> loadFeedback() async {
    loadingFeedback.value = true;
    campaigns.value = await _campaignService.getAll();
    final linkedId = nursery.value.kidtrackFeedbackCampaignId ?? '';
    currentCampaign.value = linkedId.isEmpty
        ? null
        : campaigns.firstWhereOrNull((c) => c.key == linkedId);

    if (currentCampaign.value != null) {
      feedbackStats.value = await _feedbackService.getStats(
        nurseryId: nursery.value.key ?? '',
        campaignId: linkedId,
      );
    } else {
      feedbackStats.value = null;
    }
    loadingFeedback.value = false;
  }

  void openCampaignPicker() {
    Get.bottomSheet(
      CampaignPickerSheet(
        campaigns: campaigns,
        currentId: nursery.value.kidtrackFeedbackCampaignId,
        onPick: assignCampaign,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  Future<void> assignCampaign(String campaignId) async {
    final nurseryId = nursery.value.key ?? '';
    if (nurseryId.isEmpty || campaignId.isEmpty) return;
    Loader.show();
    try {
      await FirebaseDatabase.instance
          .ref('${ApiPaths.globalNurseries}/$nurseryId')
          .update({
        'kidtrackFeedbackCampaignId': campaignId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      nursery.value =
          nursery.value.copyWith(kidtrackFeedbackCampaignId: campaignId);
      Loader.dismiss();
      Loader.showSuccess('sa_feedback_assigned'.tr);
      await loadFeedback();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }

  Future<void> disableCampaign() async {
    final nurseryId = nursery.value.key ?? '';
    if (nurseryId.isEmpty) return;
    Loader.show();
    try {
      // Null clears the link — copyWith can't express this, so write directly.
      await FirebaseDatabase.instance
          .ref('${ApiPaths.globalNurseries}/$nurseryId')
          .update({
        'kidtrackFeedbackCampaignId': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      await _reloadNurseryFromRegistry();
      Loader.dismiss();
      Loader.showSuccess('sa_feedback_disabled'.tr);
      await loadFeedback();
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }

  Future<void> sendReminders() async {
    final campaign = currentCampaign.value;
    final nurseryId = nursery.value.key ?? '';
    if (campaign == null || nurseryId.isEmpty) return;
    Loader.show();
    try {
      final sent = await _feedbackService.sendReminders(
        nurseryId: nurseryId,
        campaignId: campaign.key ?? '',
        title: 'sa_feedback_reminder_title'.tr,
        body: campaign.title,
      );
      Loader.dismiss();
      Loader.showSuccess(
          'sa_feedback_reminder_sent'.trParams({'count': '$sent'}));
    } catch (_) {
      Loader.dismiss();
      Loader.showError('sa_feedback_error'.tr);
    }
  }

  void openResponses() {
    final campaign = currentCampaign.value;
    if (campaign == null) return;
    Get.toNamed(kidtrackFeedbackResponsesView, arguments: {
      'nurseryId': nursery.value.key ?? '',
      'campaignId': campaign.key ?? '',
      'nurseryName': nursery.value.name,
      'campaignTitle': campaign.title,
    });
  }

  Future<void> _reloadNurseryFromRegistry() async {
    final key = nursery.value.key;
    if (key == null) return;
    final snap = await FirebaseDatabase.instance
        .ref('${ApiPaths.globalNurseries}/$key')
        .get();
    if (snap.exists && snap.value is Map) {
      nursery.value = NurseryModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
        key: key,
      );
    }
  }
}
