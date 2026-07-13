import 'package:firebase_database/firebase_database.dart';
import '../Utils/logger.dart';
import 'session_service.dart';

/// Per-parent push-notification preferences in Realtime Database.
///
/// Storage (read by the notification Cloud Functions — functions/shared/
/// notifPrefs.js) lives on the same top-level user node as the FCM token:
///   users/{uid}/notifPrefs = { attendance: bool, activities: bool }
///
/// Defaults when the node/field is missing (mirrored in the Cloud Function):
///   attendance → true  (on from day one, even before the parent opens settings)
///   activities → false (opt-in; the parent turns it on themselves)
///
/// The absence of the whole node also signals "first time" — the onboarding
/// prompt shows the settings sheet once, and saving writes the node so it never
/// reappears (see NotificationPrefsPrompt). Direct RTDB access here mirrors
/// [FcmTokenService]; controllers reach this only through Get.find.
class NotificationPrefsService {
  NotificationPrefsService._internal();
  static final NotificationPrefsService _instance =
      NotificationPrefsService._internal();
  factory NotificationPrefsService() => _instance;

  static const _tag = 'NOTIF_PREFS';
  static const _attendanceDefault = true;
  static const _activitiesDefault = false;

  final _db = FirebaseDatabase.instance;

  String? get _uid => SessionService().userId;

  DatabaseReference? _ref() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return null;
    return _db.ref('users/$uid/notifPrefs');
  }

  /// Whether the parent has ever saved their preferences. Used to decide the
  /// first-time prompt: a missing node means "not configured yet".
  Future<bool> exists() async {
    final ref = _ref();
    if (ref == null) return false;
    try {
      final snap = await ref.get();
      return snap.exists;
    } catch (e) {
      AppLogger.error(_tag, 'exists: $e');
      // On error assume configured so we never trap the parent in the prompt.
      return true;
    }
  }

  /// Current preferences, falling back to the defaults for any missing field.
  Future<({bool attendance, bool activities})> read() async {
    final ref = _ref();
    if (ref == null) {
      return (attendance: _attendanceDefault, activities: _activitiesDefault);
    }
    try {
      final snap = await ref.get();
      final data = snap.value as Map?;
      return (
        attendance: data?['attendance'] as bool? ?? _attendanceDefault,
        activities: data?['activities'] as bool? ?? _activitiesDefault,
      );
    } catch (e) {
      AppLogger.error(_tag, 'read: $e');
      return (attendance: _attendanceDefault, activities: _activitiesDefault);
    }
  }

  /// Persists both toggles. Writing the node also clears the first-time prompt.
  Future<void> save({
    required bool attendance,
    required bool activities,
  }) async {
    final ref = _ref();
    if (ref == null) throw StateError('No signed-in user for notifPrefs');
    await ref.set({'attendance': attendance, 'activities': activities});
  }
}
