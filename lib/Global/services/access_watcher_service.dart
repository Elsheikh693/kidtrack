import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../Data/models/user/user_type.dart';
import '../../routing/routing.dart';
import '../Utils/logger.dart';
import 'access_control_service.dart';
import 'session_service.dart';

/// Live access guard. Generalizes the old staff-only watcher to cover every
/// role plus the nursery subscription, using the same predicates as
/// [AccessControlService]. Two cheap node listeners (own membership record +
/// nursery `info`) force-logout the moment access is revoked — even while the
/// user is mid-session.
class AccessWatcherService extends GetxController {
  static AccessWatcherService get to => Get.find<AccessWatcherService>();

  StreamSubscription<DatabaseEvent>? _recordSub;
  StreamSubscription<DatabaseEvent>? _nurserySub;

  // ── Start ───────────────────────────────────────────────────────────────────

  /// Begins watching based on the current session. Idempotent — cancels any
  /// previous subscriptions first. No-op for guests / superAdmin.
  void start() {
    stop();

    final session = SessionService();
    final uid = session.currentUser?.uid;
    final role = session.userType;
    final nurseryId = session.nurseryId ?? '';

    if (uid == null || role == UserType.superAdmin) return;

    // Nursery suspension watch (covers everyone in the tenant).
    if (nurseryId.isNotEmpty) {
      _nurserySub = FirebaseDatabase.instance
          .ref('platform/$nurseryId/info')
          .onValue
          .listen(_onNursery, onError: _onError);
    }

    // Own membership record watch (parent / staff — owner is gated by nursery).
    final recordPath = _recordPathFor(role, nurseryId, uid);
    if (recordPath != null) {
      AppLogger.info('ACCESS_WATCHER', 'Watching → $recordPath');
      _recordSub = FirebaseDatabase.instance
          .ref(recordPath)
          .onValue
          .listen(_onRecord, onError: _onError);
    }
  }

  String? _recordPathFor(UserType? role, String nurseryId, String uid) {
    if (nurseryId.isEmpty || role == null) return null;
    if (role == UserType.parent) return 'platform/$nurseryId/parents/$uid';
    if (role.isStaffRole && role != UserType.owner) {
      return 'platform/$nurseryId/staff/$uid';
    }
    return null;
  }

  // ── Listeners ─────────────────────────────────────────────────────────────────

  void _onRecord(DatabaseEvent event) {
    final snap = event.snapshot;
    if (!snap.exists || snap.value == null) {
      _forceLogout('access_denied_account_removed');
      return;
    }
    if (AccessControlService.isExplicitlyInactive(snap)) {
      _forceLogout('access_denied_account_deactivated');
    }
  }

  void _onNursery(DatabaseEvent event) {
    if (!AccessControlService.isExplicitlyInactive(event.snapshot)) return;

    if (SessionService().userType == UserType.owner) {
      // Owner keeps their session but is routed to the renewal screen.
      stop();
      Get.offAllNamed(renewalView);
    } else {
      _forceLogout('access_denied_nursery_suspended');
    }
  }

  void _onError(Object e) =>
      AppLogger.warning('ACCESS_WATCHER', 'Stream error: $e');

  // ── Stop ────────────────────────────────────────────────────────────────────

  void stop() {
    _recordSub?.cancel();
    _nurserySub?.cancel();
    _recordSub = null;
    _nurserySub = null;
  }

  // ── Force Logout ─────────────────────────────────────────────────────────────

  Future<void> _forceLogout(String reasonKey) async {
    stop();
    AppLogger.warning('ACCESS_WATCHER', 'Access revoked — $reasonKey');
    await SessionService().clear();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    Get.offAllNamed(activationLandingView);
    await Future.delayed(const Duration(milliseconds: 400));
    Get.snackbar(
      '',
      reasonKey.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
