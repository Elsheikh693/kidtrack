import 'storage_service.dart';

/// On-device record of "this account finished first-login setup", keyed per uid.
///
/// The server flags (`users/{uid}/setupDone`, teacher `isSetupDone`) are the
/// cross-device source of truth, but they can be wiped by an admin re-saving the
/// owner record, or read stale from cache — which made the setup screen reappear
/// on every login. This local marker is the reliable per-device gate: once set
/// it survives logout (see [StorageService.clearAll] prefix-preserve), so a
/// returning user never sees setup twice on the same device.
class SetupLocalCheck {
  /// Keys are exposed via this prefix so logout can preserve them in bulk.
  static const String keyPrefix = 'setup_done_';

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
