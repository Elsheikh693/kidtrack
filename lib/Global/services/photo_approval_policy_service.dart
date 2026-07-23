import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'session_service.dart';

/// Nursery-wide policy flag: whether photos uploaded by teachers (activity
/// photos AND event "fun day" photos) must be reviewed before guardians see
/// them. Persisted on the nursery record
/// (`platform/info/{nurseryId}/photosNeedApproval`), defaults to `true` (the
/// current review flow).
///
/// When turned OFF, the upload services publish photos immediately
/// (`isApproved: true`) so they reach guardians without a review step. The
/// upload path reads the raw flag directly at upload time; this shared reactive
/// holder backs the manager/owner settings toggle.
class PhotoApprovalPolicyService extends GetxService {
  /// True = review required before parents (default). False = straight to
  /// parents.
  final needsApproval = true.obs;
  final isSaving = false.obs;
  bool _loaded = false;

  String get _nurseryId => SessionService().nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$_nurseryId');

  /// One-shot read. Safe to call repeatedly; only hits the network once unless
  /// [force] is set. A missing value defaults to `true` so the review flow is
  /// preserved for nurseries that never touched the setting.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final id = _nurseryId;
    if (id.isEmpty) return;
    try {
      final snap = await _ref.child('photosNeedApproval').get();
      final v = snap.value;
      // Only an explicit "false-ish" value turns approval off; missing = true.
      needsApproval.value = !(v == false || v == 0 || v == '0' || v == 'false');
      _loaded = true;
    } catch (_) {
      // keep whatever is cached (defaults to true)
    }
  }

  /// Partial update — never touches the nursery's other profile fields.
  Future<bool> setEnabled(bool value) async {
    final id = _nurseryId;
    if (id.isEmpty) return false;
    isSaving.value = true;
    final previous = needsApproval.value;
    needsApproval.value = value; // optimistic
    try {
      await _ref.update({'photosNeedApproval': value});
      _loaded = true;
      return true;
    } catch (_) {
      needsApproval.value = previous; // roll back on failure
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
