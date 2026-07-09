import 'storage_service.dart';

/// On-device record of the LAST KidTrack app-rating campaign a parent answered,
/// keyed per uid. Unlike a boolean gate, storing the campaign id means a NEW
/// campaign (different id) auto-re-shows the prompt with no code change.
///
/// Firebase (`platformFeedback/{nurseryId}/{campaignId}/{parentId}`) is the
/// cross-device source of truth; this local marker short-circuits the launch
/// check so we don't hit Firebase on every cold start. It survives logout (see
/// [StorageService.clearAll] prefix-preserve).
class KidtrackFeedbackGate {
  /// Exposed as a prefix so logout can preserve these markers in bulk.
  static const String keyPrefix = 'kidtrack_feedback_done_';

  static final _storage = StorageService();

  static String _keyFor(String uid) => '$keyPrefix$uid';

  /// The campaign id this parent last answered, or empty if none.
  static String lastAnswered(String uid) {
    if (uid.isEmpty) return '';
    return _storage.getData(_keyFor(uid))?['campaignId']?.toString() ?? '';
  }

  /// True when this parent has already answered the given campaign.
  static bool isDone(String uid, String campaignId) {
    if (uid.isEmpty || campaignId.isEmpty) return false;
    return lastAnswered(uid) == campaignId;
  }

  static Future<void> markDone(String uid, String campaignId) {
    if (uid.isEmpty || campaignId.isEmpty) return Future.value();
    return _storage.setData(_keyFor(uid), {'campaignId': campaignId});
  }
}
