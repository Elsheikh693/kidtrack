import 'package:flutter/material.dart';

// Shared visual language for the parent Daily Journal.

const kJBg = Color(0xFFF4F4F8);
const kJInk = Color(0xFF0F172A);
const kJMuted = Color(0xFF64748B);
const kJBorder = Color(0xFFEEF0F4);

const _palette = [
  Color(0xFF6C4DDB),
  Color(0xFF2563EB),
  Color(0xFF059669),
  Color(0xFFD97706),
  Color(0xFF7C3AED),
  Color(0xFF0EA5E9),
  Color(0xFFDB2777),
];

Color journalSubjectColor(String seed) =>
    _palette[seed.hashCode.abs() % _palette.length];

/// Event-type icon for the timeline, inferred from the subject name keywords.
/// Uses Material icons (always render — unlike emoji under the app's Arabic
/// font, which fall back to tofu "?").
IconData journalEventIcon(String subjectName) {
  final s = subjectName.toLowerCase();
  bool has(List<String> keys) => keys.any(s.contains);
  if (has(['قرآن', 'تجويد', 'تحفيظ'])) return Icons.auto_stories_rounded;
  if (has(['english', 'إنجليز', 'phonics', 'فونيك', 'letter', 'abc'])) {
    return Icons.abc_rounded;
  }
  if (has(['عرب', 'arabic', 'لغة', 'كتابة', 'قراءة', 'حروف', 'إملاء'])) {
    return Icons.menu_book_rounded;
  }
  if (has(['رياضيات', 'حساب', 'math', 'عدد', 'أرقام', 'عد'])) {
    return Icons.calculate_rounded;
  }
  if (has(['فن', 'رسم', 'art', 'تلوين', 'أشغال'])) return Icons.palette_rounded;
  if (has(['موسيق', 'music', 'نشيد', 'أناشيد', 'غناء'])) {
    return Icons.music_note_rounded;
  }
  if (has(['رياضة', 'حرك', 'sport', 'ألعاب', 'لعب', 'جري'])) {
    return Icons.sports_soccer_rounded;
  }
  if (has(['علوم', 'science', 'اكتشاف', 'تجربة'])) return Icons.science_rounded;
  if (has(['دين', 'إسلام', 'صلاة', 'أخلاق'])) return Icons.mosque_rounded;
  if (has(['اجتماع', 'سلوك', 'مشاركة', 'تعاون'])) return Icons.groups_rounded;
  if (has(['واجب', 'homework'])) return Icons.assignment_rounded;
  return Icons.auto_stories_rounded;
}

/// Per-activity evaluation chip (teacher scale) — label + color + icon.
({String label, Color color, IconData icon}) evalChipMeta(String level) {
  switch (level) {
    case 'excellent':
      return (
        label: 'ممتاز',
        color: const Color(0xFF059669),
        icon: Icons.star_rounded,
      );
    case 'needs_follow':
      return (
        label: 'جيد جدًا',
        color: const Color(0xFF2563EB),
        icon: Icons.thumb_up_rounded,
      );
    case 'needs_attention':
      return (
        label: 'يحتاج متابعة',
        color: const Color(0xFFD97706),
        icon: Icons.error_rounded,
      );
    default:
      return (
        label: 'تم',
        color: const Color(0xFF64748B),
        icon: Icons.check_circle_rounded,
      );
  }
}

/// Overall day mood for the hero card — label + icon + color.
({String label, IconData icon, Color color}) dayOverallMeta(String? level) {
  switch (level) {
    case 'excellent':
      return (
        label: 'يوم ممتاز',
        icon: Icons.star_rounded,
        color: const Color(0xFF059669),
      );
    case 'needs_follow':
      return (
        label: 'يوم جيد',
        icon: Icons.sentiment_satisfied_rounded,
        color: const Color(0xFF2563EB),
      );
    case 'needs_attention':
      return (
        label: 'يحتاج متابعة',
        icon: Icons.sentiment_neutral_rounded,
        color: const Color(0xFFD97706),
      );
    default:
      return (
        label: 'بدون تقييم',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF64748B),
      );
  }
}

const _kArDays = [
  'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
];
const _kArMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// "اليوم" / "أمس" / "السبت 20 يونيو"
String journalDateLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  return '${_kArDays[that.weekday - 1]} ${that.day} ${_kArMonths[that.month - 1]}';
}

/// Full label, always with the weekday — used in the hero header.
String journalFullDate(DateTime d) =>
    '${_kArDays[d.weekday - 1]} ${d.day} ${_kArMonths[d.month - 1]}';

String journalClock(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  final h24 = dt.hour;
  final period = h24 < 12 ? 'ص' : 'م';
  var h = h24 % 12;
  if (h == 0) h = 12;
  return '$h:${dt.minute.toString().padLeft(2, '0')} $period';
}
