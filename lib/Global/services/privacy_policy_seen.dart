import 'storage_service.dart';

/// On-device record of "this parent has already accepted the nursery's privacy
/// policy on first app open", keyed per uid.
///
/// The privacy policy is a mandatory, non-dismissible acceptance shown once —
/// so completion of the sheet (checkbox + accept) is what writes this marker.
/// It survives logout (see [StorageService.clearAll] prefix-preserve) so a
/// returning parent who already accepted is never re-prompted on this device.
class PrivacyPolicySeen {
  /// Keys are exposed via this prefix so logout can preserve them in bulk.
  static const String keyPrefix = 'privacy_policy_seen_';

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
