import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Global/Utils/date_helpers.dart';

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
        label: 'parenteduc24_eval_excellent'.tr,
        color: const Color(0xFF059669),
        icon: Icons.star_rounded,
      );
    case 'needs_follow':
      return (
        label: 'parenteduc24_eval_very_good'.tr,
        color: const Color(0xFF2563EB),
        icon: Icons.thumb_up_rounded,
      );
    case 'needs_attention':
      return (
        label: 'parenteduc24_eval_needs_follow'.tr,
        color: const Color(0xFFD97706),
        icon: Icons.error_rounded,
      );
    default:
      return (
        label: 'parenteduc24_eval_done'.tr,
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
        label: 'parenteduc24_day_excellent'.tr,
        icon: Icons.star_rounded,
        color: const Color(0xFF059669),
      );
    case 'needs_follow':
      return (
        label: 'parenteduc24_day_good'.tr,
        icon: Icons.sentiment_satisfied_rounded,
        color: const Color(0xFF2563EB),
      );
    case 'needs_attention':
      return (
        label: 'parenteduc24_eval_needs_follow'.tr,
        icon: Icons.sentiment_neutral_rounded,
        color: const Color(0xFFD97706),
      );
    default:
      return (
        label: 'parenteduc24_day_no_eval'.tr,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF64748B),
      );
  }
}

/// "اليوم" / "أمس" / "السبت 20 يونيو"
String journalDateLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'filter_today'.tr;
  if (diff == 1) return 'filter_yesterday'.tr;
  return '${weekdayName(that.weekday)} ${that.day} ${monthName(that.month)}';
}

/// Full label, always with the weekday — used in the hero header.
String journalFullDate(DateTime d) =>
    '${weekdayName(d.weekday)} ${d.day} ${monthName(d.month)}';

String journalClock(int ms) => arabicClockTime(ms);
