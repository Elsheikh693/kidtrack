import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../Data/models/user/user_type.dart';
import '../Utils/logger.dart';
import 'activation_login_service.dart';
import 'session_service.dart';

/// What the gate decided the app should do for the current user.
enum AccessAction { allowed, toLogin, toRenewal }

class AccessOutcome {
  final AccessAction action;

  /// Localization key for the message shown after a block (null = silent).
  final String? reasonKey;

  const AccessOutcome(this.action, [this.reasonKey]);
}

/// Single source of truth for "is this user still allowed in?".
///
/// Two entry points share the same rules:
///  • [validateOnce] — one-shot check on app open (MainPage gate) and after login.
///  • the live [AccessWatcherService] — same predicates, but reactive.
class AccessControlService {
  AccessControlService._();
  static final AccessControlService _instance = AccessControlService._();
  factory AccessControlService() => _instance;

  final _db = FirebaseDatabase.instance;

  /// Validates the restored session against the server.
  ///
  /// Fails **open** on network errors: a flaky connection must never lock out a
  /// legitimate user. Real revocations are still caught live by
  /// [AccessWatcherService] once connectivity returns.
  Future<AccessOutcome> validateOnce() async {
    final session = SessionService();
    var user = FirebaseAuth.instance.currentUser;

    // Self-heal: the local login state survived but the Firebase Auth session
    // was lost (keychain wipe, token-refresh failure, cleared app data). Re-mint
    // it silently from the durable activation code instead of dumping the user
    // back on the code screen — the code never expires, so this should succeed.
    if (user == null && session.isLoggedIn) {
      await Get.find<ActivationLoginService>().silentReactivate();
      user = FirebaseAuth.instance.currentUser;
    }

    if (user == null || !session.isLoggedIn) {
      return const AccessOutcome(AccessAction.toLogin);
    }

    final uid = user.uid;
    final role = session.userType;
    final nurseryId = session.nurseryId ?? '';

    // Platform-wide admin bypasses every tenant gate.
    if (role == UserType.superAdmin) {
      return const AccessOutcome(AccessAction.allowed);
    }

    try {
      // 1) Account record still exists.
      final userSnap = await _db.ref('users/$uid').get();
      if (!userSnap.exists) {
        return const AccessOutcome(
          AccessAction.toLogin,
          'access_denied_account_removed',
        );
      }

      // 2) Nursery still active (subscription / payment gate).
      if (nurseryId.isNotEmpty) {
        final infoSnap = await _db.ref('platform/$nurseryId/info').get();
        if (_isExplicitlyInactive(infoSnap)) {
          // Owner may enter to renew; everyone else is turned away.
          return role == UserType.owner
              ? const AccessOutcome(AccessAction.toRenewal)
              : const AccessOutcome(
                  AccessAction.toLogin,
                  'access_denied_nursery_suspended',
                );
        }
      }

      // 3) Role-specific membership still active.
      if (role == UserType.parent) {
        final snap = await _db.ref('platform/$nurseryId/parents/$uid').get();
        final blocked = _membershipBlock(snap);
        if (blocked != null) return AccessOutcome(AccessAction.toLogin, blocked);
      } else if (role != null &&
          role.isStaffRole &&
          role != UserType.owner) {
        final snap = await _db.ref('platform/$nurseryId/staff/$uid').get();
        final blocked = _membershipBlock(snap);
        if (blocked != null) return AccessOutcome(AccessAction.toLogin, blocked);
      }

      return const AccessOutcome(AccessAction.allowed);
    } catch (e) {
      AppLogger.warning('ACCESS', 'validateOnce error — failing open: $e');
      return const AccessOutcome(AccessAction.allowed);
    }
  }

  /// Returns a reason key if the membership record blocks access, else null.
  static String? _membershipBlock(DataSnapshot snap) {
    if (!snap.exists || snap.value == null) return 'access_denied_account_removed';
    if (_isExplicitlyInactive(snap)) return 'access_denied_account_deactivated';
    return null;
  }

  /// True only when `isActive` is explicitly false/0. A missing field defaults
  /// to active so legacy records (created before the flag existed) are not
  /// locked out.
  static bool isExplicitlyInactive(DataSnapshot snap) =>
      _isExplicitlyInactive(snap);

  static bool _isExplicitlyInactive(DataSnapshot snap) {
    if (!snap.exists || snap.value is! Map) return false;
    final v = (snap.value as Map)['isActive'];
    if (v == null) return false;
    if (v is bool) return v == false;
    if (v is int) return v == 0;
    if (v is String) return v == '0' || v.toLowerCase() == 'false';
    return false;
  }
}
