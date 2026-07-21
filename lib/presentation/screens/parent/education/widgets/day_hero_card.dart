import 'package:flutter/material.dart';
import '../controller.dart';
import 'journal_meta.dart';

/// Hero summary: "what kind of day did my child have?" — read in 3 seconds.
class DayHeroCard extends StatelessWidget {
  const DayHeroCard({
    super.key,
    required this.childName,
    required this.summary,
  });

  final String childName;
  final DaySummary summary;

  String get _firstName =>
      childName.trim().isEmpty ? 'طفلك' : childName.trim().split(' ').first;

  String get _activityLine {
    final n = summary.activityCount;
    if (n == 0) return 'لم يبدأ أنشطة اليوم';
    if (n == 1) return '$_firstName شارك في نشاط واحد';
    if (n == 2) return '$_firstName شارك في نشاطين';
    return '$_firstName شارك في $n أنشطة';
  }

  @override
  Widget build(BuildContext context) {
    final m = dayOverallMeta(summary.overallEval);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [m.color.withValues(alpha: 0.14), m.color.withValues(alpha: 0.04)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: m.color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: m.color.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Icon(m.icon, size: 30, color: m.color),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date selector intentionally hidden here: parents browse
                    // past days from the Link Book (دفتر التواصل) instead, so a
                    // second date picker on the home hero was redundant.
                    const Text(
                      'تقييم اليوم',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kJMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.label,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: m.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryLine(
            icon: Icons.bolt_rounded,
            text: _activityLine,
            color: const Color(0xFF2563EB),
          ),
          if (summary.homeworkTotal > 0) ...[
            const SizedBox(height: 9),
            _SummaryLine(
              icon: Icons.assignment_turned_in_rounded,
              text: 'أكمل ${summary.homeworkDone} من ${summary.homeworkTotal} واجب',
              color: const Color(0xFF8E44AD),
            ),
          ],
          const SizedBox(height: 9),
          _SummaryLine(
            icon: summary.negativeNotes == 0
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            text: summary.negativeNotes == 0
                ? 'لا توجد ملاحظات سلبية'
                : '${summary.negativeNotes} ملاحظة تحتاج انتباه',
            color: summary.negativeNotes == 0
                ? const Color(0xFF059669)
                : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w600, color: kJInk),
          ),
        ),
      ],
    );
  }
}
