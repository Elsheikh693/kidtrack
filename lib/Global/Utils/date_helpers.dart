import 'package:intl/intl.dart';

String convertArabicToEnglishNumbers(String input) {
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }
  return input;
}

String toDashFormat(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

const _arabicWeekdays = <String>[
  'الاثنين', // weekday 1
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد', // weekday 7
];

const _arabicMonths = <String>[
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// Full Arabic date, e.g. "الأحد، 22 يونيو 2026".
/// Built manually so it works without initializing intl locale data.
String arabicFullDate([DateTime? date]) {
  final d = date ?? DateTime.now();
  final day = _arabicWeekdays[d.weekday - 1];
  final month = _arabicMonths[d.month - 1];
  return '$day، ${d.day} $month ${d.year}';
}

/// Compact `1,250` style money formatting — no decimals, thousands separators.
String formatAmount(num value) {
  final v = value.round();
  final neg = v < 0;
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}$buf';
}

/// Month + year label, e.g. "يونيو 2026". Manual so it works without
/// initializing intl locale data.
String arabicMonthYear([DateTime? date]) {
  final d = date ?? DateTime.now();
  return '${_arabicMonths[d.month - 1]} ${d.year}';
}

/// 12-hour clock with an Arabic ص/م suffix, e.g. "7:35 م".
/// Built manually to avoid depending on intl locale initialization.
String arabicClockTime(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final isPm = d.hour >= 12;
  var h = d.hour % 12;
  if (h == 0) h = 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${isPm ? 'م' : 'ص'}';
}

/// First school day strictly after [from] (defaults to today), i.e. the default
/// Homework Date. [workingDays] are Dart weekday ints (Mon=1 … Sun=7); pass the
/// nursery's `effectiveWorkingDays` so it's never empty. Falls back to tomorrow
/// if no working day is found within two weeks.
DateTime nextSchoolDay(List<int> workingDays, {DateTime? from}) {
  final base = from ?? DateTime.now();
  final days = workingDays.where((d) => d >= 1 && d <= 7).toSet();
  var d = DateTime(base.year, base.month, base.day).add(const Duration(days: 1));
  for (var i = 0; i < 14; i++) {
    if (days.isEmpty || days.contains(d.weekday)) return d;
    d = d.add(const Duration(days: 1));
  }
  return d;
}

String normalizeToDashDate(String? date) {
  if (date == null || date.isEmpty) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  try {
    // dd/MM/yyyy
    if (date.contains('/')) {
      final parsed = DateFormat('dd/MM/yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // dd-MM-yyyy (already correct)
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      return date;
    }

    // fallback
    final parsed = DateTime.tryParse(date);
    if (parsed != null) {
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    return date;
  } catch (_) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
}
