import 'storage_service.dart';

/// On-device record of "this parent already gave the nursery its first-open
/// feedback", keyed per uid.
///
/// Firebase (`platform/{nurseryId}/feedback/{parentId}`) is the cross-device
/// source of truth, but this local marker short-circuits the launch check so we
/// don't hit Firebase on every cold start. It survives logout (see
/// [StorageService.clearAll] prefix-preserve) so a returning parent on the same
/// device never sees the mandatory sheet twice.
class NurseryFeedbackGate {
  /// Exposed as a prefix so logout can preserve these markers in bulk.
  static const String keyPrefix = 'nursery_feedback_done_';

  static final _storage = StorageService();

  static String _keyFor(String uid) => '$keyPrefix$uid';

  static bool isDone(String uid) {
    if (uid.isEmpty) return false;
    return _storage.getData(_keyFor(uid))?['done'] == true;
  }

  static Future<void> markDone(String uid) {
    if (uid.isEmpty) return Future.value();
    return _storage.setData(_keyFor(uid), {'done': true});
  }
}
