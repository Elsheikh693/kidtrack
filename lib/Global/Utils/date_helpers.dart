import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// True when the app is currently showing Arabic. Defaults to Arabic when no
/// locale is set. Drives every locale-aware date/number helper below.
bool get _isAr => (Get.locale?.languageCode ?? 'ar') != 'en';

String convertArabicToEnglishNumbers(String input) {
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }
  return input;
}

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Render Western digits in the active language: Arabic-Indic under Arabic,
/// untouched under English. Use for any number shown inside a date/time string.
String localizeDigits(String input) {
  if (!_isAr) return input;
  final buf = StringBuffer();
  for (final ch in input.codeUnits) {
    if (ch >= 0x30 && ch <= 0x39) {
      buf.write(_arabicDigits[ch - 0x30]);
    } else {
      buf.writeCharCode(ch);
    }
  }
  return buf.toString();
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

const _englishWeekdays = <String>[
  'Monday', // weekday 1
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday', // weekday 7
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

const _englishMonths = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Locale-aware list separator between weekday and the rest of a date.
/// AR: "، " (Arabic comma) · EN: ", ".
String get dateSep => _isAr ? '، ' : ', ';

/// Locale-aware month name for a 1-based month (1 = Jan … 12 = Dec).
String monthName(int month) =>
    (_isAr ? _arabicMonths : _englishMonths)[(month - 1) % 12];

/// Locale-aware weekday name for a Dart weekday int (1 = Mon … 7 = Sun).
String weekdayName(int weekday) =>
    (_isAr ? _arabicWeekdays : _englishWeekdays)[(weekday - 1) % 7];

/// Full localized date.
/// AR: "الأحد، 22 يونيو 2026" · EN: "Sunday, 22 June 2026".
/// Built manually so it works without initializing intl locale data.
String arabicFullDate([DateTime? date]) {
  final d = date ?? DateTime.now();
  final day = weekdayName(d.weekday);
  final month = monthName(d.month);
  final sep = _isAr ? '، ' : ', ';
  return localizeDigits('$day$sep${d.day} $month ${d.year}');
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

/// Month + year label. AR: "يونيو 2026" · EN: "June 2026". Manual so it works
/// without initializing intl locale data.
String arabicMonthYear([DateTime? date]) {
  final d = date ?? DateTime.now();
  return localizeDigits('${monthName(d.month)} ${d.year}');
}

/// 12-hour clock with a localized meridiem suffix.
/// AR: "7:35 م" · EN: "7:35 PM". Built manually to avoid depending on intl
/// locale initialization.
String arabicClockTime(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final isPm = d.hour >= 12;
  var h = d.hour % 12;
  if (h == 0) h = 12;
  final m = d.minute.toString().padLeft(2, '0');
  final suffix = _isAr ? (isPm ? 'م' : 'ص') : (isPm ? 'PM' : 'AM');
  return localizeDigits('$h:$m $suffix');
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
