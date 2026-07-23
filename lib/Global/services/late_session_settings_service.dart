import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'session_service.dart';

/// Manager setting: how long after a scheduled session's start time we wait
/// before flagging that the (present) teacher hasn't started it. Persisted on
/// the nursery record (`platform/info/{nurseryId}`):
///   • lateSessionAlertEnabled   — master on/off (default ON)
///   • lateSessionGraceMinutes   — minutes after start before nudging the TEACHER
///   • lateSessionEscalateMinutes — extra minutes before escalating to the MANAGER
///
/// The live manager card reads these client-side; the `lateSessionStartScan`
/// Cloud Function reads the same raw keys server-side. Shared reactive holder.
class LateSessionSettingsService extends GetxService {
  static const int defaultGrace = 15;
  static const int defaultEscalate = 15;

  final enabled = true.obs;
  final graceMinutes = defaultGrace.obs;
  final escalateMinutes = defaultEscalate.obs;
  final isSaving = false.obs;
  bool _loaded = false;

  String get _nurseryId => SessionService().nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$_nurseryId');

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final id = _nurseryId;
    if (id.isEmpty) return;
    try {
      final snap = await _ref.get();
      final map = snap.value is Map
          ? Map<String, dynamic>.from(snap.value as Map)
          : const {};
      if (map.containsKey('lateSessionAlertEnabled')) {
        enabled.value = map['lateSessionAlertEnabled'] == true;
      }
      graceMinutes.value =
          _asMinutes(map['lateSessionGraceMinutes']) ?? defaultGrace;
      escalateMinutes.value =
          _asMinutes(map['lateSessionEscalateMinutes']) ?? defaultEscalate;
      _loaded = true;
    } catch (_) {
      // keep whatever is cached
    }
  }

  Future<bool> save({
    required bool enabled,
    required int grace,
    required int escalate,
  }) async {
    final id = _nurseryId;
    if (id.isEmpty) return false;
    isSaving.value = true;
    final prev = (this.enabled.value, graceMinutes.value, escalateMinutes.value);
    // optimistic
    this.enabled.value = enabled;
    graceMinutes.value = grace.clamp(1, 180);
    escalateMinutes.value = escalate.clamp(1, 180);
    try {
      await _ref.update({
        'lateSessionAlertEnabled': enabled,
        'lateSessionGraceMinutes': graceMinutes.value,
        'lateSessionEscalateMinutes': escalateMinutes.value,
      });
      _loaded = true;
      return true;
    } catch (_) {
      this.enabled.value = prev.$1; // roll back
      graceMinutes.value = prev.$2;
      escalateMinutes.value = prev.$3;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  static int? _asMinutes(dynamic v) {
    if (v == null) return null;
    final n = v is int ? v : int.tryParse(v.toString());
    if (n == null) return null;
    return n.clamp(1, 180);
  }
}
