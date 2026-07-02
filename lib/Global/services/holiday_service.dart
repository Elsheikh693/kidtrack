import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/holiday/holiday_model.dart';
import 'session_service.dart';

/// Nursery-wide days off. Two independent sources, both under the nursery:
///   • Specific dates   → `platform/{nurseryId}/holidays/{yyyy-MM-dd}`
///   • Weekly weekend    → `platform/{nurseryId}/holidaySettings/weekendDays`
///     (a map of DateTime.weekday int → true, e.g. {"5":true,"6":true} = Fri+Sat)
class HolidayService {
  final _db = FirebaseDatabase.instance;
  final _session = SessionService();

  String get _nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _holidaysRef =>
      _db.ref('platform/$_nurseryId/holidays');

  DatabaseReference get _weekendRef =>
      _db.ref('platform/$_nurseryId/holidaySettings/weekendDays');

  // ─── Watch specific holiday dates ──────────────────────────────────────────
  Stream<List<HolidayModel>> watchHolidays() {
    return _holidaysRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <HolidayModel>[];
      final list = <HolidayModel>[];
      for (final entry in data.entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(HolidayModel.fromJson(map, key: entry.key.toString()));
        } catch (_) {}
      }
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  // ─── Watch weekly weekend days (set of DateTime.weekday ints) ──────────────
  Stream<Set<int>> watchWeekendDays() {
    return _weekendRef.onValue.map((event) => _parseWeekend(event.snapshot.value));
  }

  Set<int> _parseWeekend(dynamic data) {
    if (data == null || data is! Map) return <int>{};
    final out = <int>{};
    for (final entry in data.entries) {
      if (entry.value == true) {
        final d = int.tryParse(entry.key.toString());
        if (d != null && d >= 1 && d <= 7) out.add(d);
      }
    }
    return out;
  }

  // ─── Mark a day as a holiday ───────────────────────────────────────────────
  Future<bool> addHoliday(DateTime day, {String label = ''}) async {
    if (_nurseryId.isEmpty) return false;
    try {
      final midnight = DateTime(day.year, day.month, day.day);
      final model = HolidayModel(
        key: dateKey(midnight),
        date: midnight.millisecondsSinceEpoch,
        label: label.trim(),
        createdBy: _session.userId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _holidaysRef.child(model.key).set(model.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Remove a holiday by its day key ───────────────────────────────────────
  Future<bool> removeHoliday(String key) async {
    if (_nurseryId.isEmpty) return false;
    try {
      await _holidaysRef.child(key).remove();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Persist the weekly weekend selection ──────────────────────────────────
  Future<bool> setWeekendDays(Set<int> days) async {
    if (_nurseryId.isEmpty) return false;
    try {
      await _weekendRef.set({for (final d in days) d.toString(): true});
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Canonical `yyyy-MM-dd` key for a day (used as the RTDB child key).
  static String dateKey(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
