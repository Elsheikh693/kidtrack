import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'session_service.dart';

/// Owner-only feature flag: whether the owner's home dashboard shows the
/// cross-branch activity-photo review banner. Persisted on the nursery record
/// (`platform/info/{nurseryId}/ownerPhotoReviewEnabled`), defaults to false.
///
/// Shared reactive holder: the settings toggle writes it, the owner dashboard
/// reads it. Managers are unaffected — their per-branch review is independent.
class OwnerPhotoReviewService extends GetxService {
  final enabled = false.obs;
  final isSaving = false.obs;
  bool _loaded = false;

  String get _nurseryId => SessionService().nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$_nurseryId');

  /// One-shot read. Safe to call repeatedly; only hits the network once unless
  /// [force] is set.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final id = _nurseryId;
    if (id.isEmpty) return;
    try {
      final snap = await _ref.child('ownerPhotoReviewEnabled').get();
      final v = snap.value;
      enabled.value = v == true || v == 1 || v == '1' || v == 'true';
      _loaded = true;
    } catch (_) {
      // keep whatever is cached (defaults to false)
    }
  }

  /// Partial update — never touches the nursery's other profile fields.
  Future<bool> setEnabled(bool value) async {
    final id = _nurseryId;
    if (id.isEmpty) return false;
    isSaving.value = true;
    final previous = enabled.value;
    enabled.value = value; // optimistic
    try {
      await _ref.update({'ownerPhotoReviewEnabled': value});
      _loaded = true;
      return true;
    } catch (_) {
      enabled.value = previous; // roll back on failure
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
