import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Utils/logger.dart';

/// Owns the FCM token lifecycle in Realtime Database.
///
/// Storage (single token per user, overwritten on refresh) — read by the
/// notification Cloud Functions (functions/shared/tokenService.js):
///   parent → users/{uid}/fcmToken
///   staff  → platform/{nurseryId}/staff/{uid}/fcmToken
///
/// Call [attach] whenever a real user becomes active (fresh login AND app start
/// with a restored session), and [detach] on logout so a signed-out device
/// stops receiving that user's pushes and the next user starts clean.
class FcmTokenService {
  FcmTokenService._internal();
  static final FcmTokenService _instance = FcmTokenService._internal();
  factory FcmTokenService() => _instance;

  static const _tag = 'FCM_TOKEN';

  final _db = FirebaseDatabase.instance;
  final _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _refreshSub;
  String? _uid;
  bool _isStaff = false;
  String? _nurseryId;

  String _pathFor(String uid, bool isStaff, String? nurseryId) => isStaff
      ? 'platform/${nurseryId ?? ''}/staff/$uid/fcmToken'
      : 'users/$uid/fcmToken';

  /// Saves the current device token for [uid] and keeps RTDB in sync with any
  /// future token rotation. Safe to call again for the same user.
  Future<void> attach({
    required String uid,
    required bool isStaff,
    String? nurseryId,
  }) async {
    _uid = uid;
    _isStaff = isStaff;
    _nurseryId = nurseryId;

    try {
      final token = await _messaging.getToken();
      if (token != null) await _write(token);
    } catch (e) {
      AppLogger.error(_tag, 'attach getToken: $e');
    }

    // App-lifetime listener (survives screen disposal) so rotations while the
    // user is logged in are persisted — the login screen is torn down after
    // navigation, so this must not live there.
    _refreshSub?.cancel();
    _refreshSub = _messaging.onTokenRefresh.listen(_write);
  }

  /// Removes the token on logout. Identity is passed explicitly (read from the
  /// session before it is cleared) so it works even when [attach] never ran
  /// this session — e.g. logging out right after an app restart.
  Future<void> detach({
    String? uid,
    bool? isStaff,
    String? nurseryId,
  }) async {
    await _refreshSub?.cancel();
    _refreshSub = null;

    final u = uid ?? _uid;
    final staff = isStaff ?? _isStaff;
    final nid = nurseryId ?? _nurseryId;

    if (u != null) {
      try {
        await _db.ref(_pathFor(u, staff, nid)).remove();
      } catch (e) {
        AppLogger.error(_tag, 'detach remove: $e');
      }
    }

    // Rotate the device token so the next signed-in user does not inherit it.
    try {
      await _messaging.deleteToken();
    } catch (e) {
      AppLogger.error(_tag, 'detach deleteToken: $e');
    }

    _uid = null;
    _isStaff = false;
    _nurseryId = null;
  }

  Future<void> _write(String token) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.ref(_pathFor(uid, _isStaff, _nurseryId)).set(token);
    } catch (e) {
      AppLogger.error(_tag, 'write: $e');
    }
  }
}
