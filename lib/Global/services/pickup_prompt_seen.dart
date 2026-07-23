import 'storage_service.dart';

/// On-device record of "this parent has already seen the first-open prompt to
/// add authorized pickup persons", keyed per uid.
///
/// The prompt is optional (skippable), so there is no server record to key off
/// like the notification-prefs gate. This local marker survives logout (see
/// [StorageService.clearAll] prefix-preserve) so the returning parent is nudged
/// only once per device.
class PickupPromptSeen {
  /// Keys are exposed via this prefix so logout can preserve them in bulk.
  static const String keyPrefix = 'pickup_prompt_seen_';

  static final _storage = StorageService();

  static String _keyFor(String uid) => '$keyPrefix$uid';

  static bool isSeen(String uid) {
    if (uid.isEmpty) return false;
    return _storage.getData(_keyFor(uid))?['seen'] == true;
  }

  static Future<void> markSeen(String uid) {
    if (uid.isEmpty) return Future.value();
    return _storage.setData(_keyFor(uid), {'seen': true});
  }
}
