import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

/// Shared formatting helpers for the teacher-reports screens.

/// "2 س 15 د" / "45 د" — compact working-time label from minutes.
String trDuration(int minutes) {
  if (minutes <= 0) return '0 ${'tr_unit_min'.tr}';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) {
    return '$h ${'tr_unit_hour'.tr} $m ${'tr_unit_min'.tr}';
  }
  if (h > 0) return '$h ${'tr_unit_hour'.tr}';
  return '$m ${'tr_unit_min'.tr}';
}

/// "الأحد 24 يونيو" — localized anchor-day label.
String trDayLabel(DateTime d) =>
    DateFormat('EEEE d MMMM', Get.locale?.toString()).format(d);

/// "9:15 ص" — start clock of an activity.
String trClock(int ms) {
  final t = DateTime.fromMillisecondsSinceEpoch(ms);
  final isAm = t.hour < 12;
  final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final m = t.minute.toString().padLeft(2, '0');
  final suffix = isAm ? 'ص' : 'م';
  return '$h:$m $suffix';
}

/// First letter of a teacher name, for avatar fallback.
String trInitial(String name) {
  final t = name.trim();
  return t.isEmpty ? '؟' : t.characters.first;
}
