import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// SuperAdmin CRUD for the global KidTrack app-rating campaigns registry at
/// `kidtrackFeedbackCampaigns/{campaignId}`.
///
/// Uses direct RTDB access (not the session-scoped 4-layer CRUD) because these
/// are platform-global objects, unbound to any nursery session.
class KidtrackCampaignService {
  final _db = FirebaseDatabase.instance;

  DatabaseReference get _root =>
      _db.ref(ApiConstants.kidtrackFeedbackCampaigns);

  /// All campaigns, newest first.
  Future<List<KidtrackFeedbackCampaignModel>> getAll() async {
    final snap = await _root.get();
    final result = <KidtrackFeedbackCampaignModel>[];
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      map.forEach((k, v) {
        if (v is Map) {
          result.add(KidtrackFeedbackCampaignModel.fromJson(
            Map<String, dynamic>.from(v),
            key: k.toString(),
          ));
        }
      });
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  /// A single campaign by id, or null.
  Future<KidtrackFeedbackCampaignModel?> getById(String campaignId) async {
    if (campaignId.isEmpty) return null;
    final snap = await _root.child(campaignId).get();
    if (snap.exists && snap.value is Map) {
      return KidtrackFeedbackCampaignModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
        key: campaignId,
      );
    }
    return null;
  }

  /// Create a campaign; returns the new id.
  Future<String> create(KidtrackFeedbackCampaignModel campaign) async {
    final id = const Uuid().v4();
    final withId = campaign.copyWith(
      key: id,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _root.child(id).set(withId.toJson());
    return id;
  }

  Future<void> update(KidtrackFeedbackCampaignModel campaign) async {
    final id = campaign.key ?? '';
    if (id.isEmpty) return;
    await _root.child(id).set(campaign.toJson());
  }

  Future<void> setEnabled(String campaignId, bool enabled) async {
    if (campaignId.isEmpty) return;
    await _root.child(campaignId).child('enabled').set(enabled);
  }

  Future<void> delete(String campaignId) async {
    if (campaignId.isEmpty) return;
    await _root.child(campaignId).remove();
  }

  /// The live campaign a nursery is currently running, or null when it has none
  /// assigned or the linked campaign is disabled. Reads the nursery's linked id
  /// from the global registry (`platform/info/{nurseryId}/...`) then the campaign.
  Future<KidtrackFeedbackCampaignModel?> activeCampaignForNursery(
      String nurseryId) async {
    if (nurseryId.isEmpty) return null;
    final linkSnap = await _db
        .ref(
            '${ApiPaths.globalNurseries}/$nurseryId/kidtrackFeedbackCampaignId')
        .get();
    final campaignId = linkSnap.value?.toString() ?? '';
    if (campaignId.isEmpty) return null;
    final campaign = await getById(campaignId);
    if (campaign == null || !campaign.enabled) return null;
    return campaign;
  }
}
