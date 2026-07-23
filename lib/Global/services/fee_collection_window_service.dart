import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'session_service.dart';

/// Manager/owner setting: the monthly fee-collection window as day-of-month
/// bounds (1..28). Persisted on the nursery record
/// (`platform/info/{nurseryId}/feeCollectionFromDay` + `…ToDay`). Both null =
/// the automatic late-fee reminder is OFF.
///
/// When set, the `feeReminderScan` Cloud Function politely chats any guardian
/// who still owes this month's fees once the window has passed. Shared reactive
/// holder: the settings screen writes it; the scan reads it server-side.
class FeeCollectionWindowService extends GetxService {
  final fromDay = RxnInt();
  final toDay = RxnInt();
  final isSaving = false.obs;
  bool _loaded = false;

  String get _nurseryId => SessionService().nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$_nurseryId');

  /// True once at least one bound is set — the reminder is only active then.
  bool get isActive => fromDay.value != null && toDay.value != null;

  /// One-shot read. Safe to call repeatedly; only hits the network once unless
  /// [force] is set.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    final id = _nurseryId;
    if (id.isEmpty) return;
    try {
      final snap = await _ref.get();
      final map = snap.value is Map
          ? Map<String, dynamic>.from(snap.value as Map)
          : const {};
      fromDay.value = _asDay(map['feeCollectionFromDay']);
      toDay.value = _asDay(map['feeCollectionToDay']);
      _loaded = true;
    } catch (_) {
      // keep whatever is cached
    }
  }

  /// Sets the window start (1..28); never lets the start exceed the end.
  Future<bool> setFromDay(int day) {
    final d = day.clamp(1, 28);
    final to = toDay.value;
    return _persist(d, (to != null && to < d) ? d : to);
  }

  /// Sets the window end (1..28); never lets the end fall before the start.
  Future<bool> setToDay(int day) {
    final d = day.clamp(1, 28);
    final from = fromDay.value;
    return _persist((from != null && from > d) ? d : from, d);
  }

  /// Clears both bounds → turns the automatic reminder off.
  Future<bool> clearWindow() => _persist(null, null);

  /// Partial update — a null value deletes that key, so it never touches the
  /// nursery's other profile fields.
  Future<bool> _persist(int? from, int? to) async {
    final id = _nurseryId;
    if (id.isEmpty) return false;
    isSaving.value = true;
    final prevFrom = fromDay.value;
    final prevTo = toDay.value;
    fromDay.value = from; // optimistic
    toDay.value = to;
    try {
      await _ref.update({
        'feeCollectionFromDay': from,
        'feeCollectionToDay': to,
      });
      _loaded = true;
      return true;
    } catch (_) {
      fromDay.value = prevFrom; // roll back on failure
      toDay.value = prevTo;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  static int? _asDay(dynamic v) {
    if (v == null) return null;
    final n = v is int ? v : int.tryParse(v.toString());
    if (n == null) return null;
    return n.clamp(1, 28);
  }
}
