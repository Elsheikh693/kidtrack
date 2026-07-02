import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Best-effort telemetry writer for parent engagement. Plants the numbers the
/// owner's Parent-Engagement metric will read in a later phase — logged from day
/// one because engagement history can't be backfilled.
///
/// Every write is fire-and-forget and swallows its own errors: engagement
/// logging must NEVER block or break the parent's experience. Uses atomic server
/// increments so concurrent opens don't clobber each other.
///
/// Target: `platform/{nurseryId}/parents/{uid}` (parent records are keyed by uid).
class ParentEngagementService {
  final SessionService _session = SessionService();

  DatabaseReference? _ref() {
    final nurseryId = _session.nurseryId ?? '';
    final uid = _session.userId ?? '';
    if (nurseryId.isEmpty || uid.isEmpty) return null;
    return FirebaseDatabase.instance.ref('platform/$nurseryId/parents/$uid');
  }

  /// Call on a successful parent login.
  Future<void> markLogin() async {
    final ref = _ref();
    if (ref == null) return;
    try {
      await ref.update({
        'lastActiveAt': ServerValue.timestamp,
        'loginCount': ServerValue.increment(1),
      });
    } catch (_) {}
  }

  /// Call when the parent opens their child's activities.
  Future<void> markActivityView() => _bump('activityViews');

  /// Call when the parent opens the feed.
  Future<void> markFeedView() => _bump('feedViews');

  Future<void> _bump(String field) async {
    final ref = _ref();
    if (ref == null) return;
    try {
      await ref.update({
        field: ServerValue.increment(1),
        'lastActiveAt': ServerValue.timestamp,
      });
    } catch (_) {}
  }
}
