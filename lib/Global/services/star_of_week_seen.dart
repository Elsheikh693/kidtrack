import 'storage_service.dart';

/// On-device record of "this parent has already seen the auto-reveal for the
/// current Star of the Week", keyed per uid and holding the last-seen star id.
///
/// Each week's pick has a distinct id (`{branchId}__{weekKey}`), so once the
/// manager names a new star the stored id no longer matches and the reveal pops
/// once more on the parent's next app open. Survives logout (prefix-preserved
/// by [StorageService.clearAll]) so a returning parent isn't shown the same
/// star twice on this device.
class StarOfWeekSeen {
  /// Keys are exposed via this prefix so logout can preserve them in bulk.
  static const String keyPrefix = 'star_of_week_seen_';

  static final _storage = StorageService();

  static String _keyFor(String uid) => '$keyPrefix$uid';

  static bool isSeen(String uid, String starId) {
    if (uid.isEmpty || starId.isEmpty) return false;
    return _storage.getData(_keyFor(uid))?['starId'] == starId;
  }

  static Future<void> markSeen(String uid, String starId) {
    if (uid.isEmpty || starId.isEmpty) return Future.value();
    return _storage.setData(_keyFor(uid), {'starId': starId});
  }
}
