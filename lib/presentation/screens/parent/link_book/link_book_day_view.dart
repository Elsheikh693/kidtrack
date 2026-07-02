import 'package:flutter/material.dart';
import '../education/widgets/journal_meta.dart';
import '../education/widgets/journal_timeline_section.dart';
import '../education/widgets/teacher_notes_section.dart';
import 'link_book_controller.dart';

/// A single page of the Link Book opened full-screen: the child's whole day.
class LinkBookDayView extends StatelessWidget {
  const LinkBookDayView({
    super.key,
    required this.day,
    required this.childName,
  });

  final LinkBookDay day;
  final String childName;

  String get _firstName =>
      childName.trim().isEmpty ? 'طفلك' : childName.trim().split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kJBg,
        appBar: AppBar(
          backgroundColor: kJBg,
          surfaceTintColor: kJBg,
          elevation: 0,
          centerTitle: true,
          title: Text(
            journalFullDate(day.date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kJInk,
            ),
          ),
          iconTheme: const IconThemeData(color: kJInk),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _DayHero(day: day, firstName: _firstName)),
            SliverToBoxAdapter(
              child: JournalTimelineSection(items: day.timeline),
            ),
            if (day.notes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                  child: TeacherNotesSection(notes: day.notes, date: day.date),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _DayHero extends StatelessWidget {
  const _DayHero({required this.day, required this.firstName});
  final LinkBookDay day;
  final String firstName;

  String get _activityLine {
    final n = day.activityCount;
    if (n == 0) return 'لا توجد أنشطة مسجلة';
    if (n == 1) return '$firstName شارك في نشاط واحد';
    if (n == 2) return '$firstName شارك في نشاطين';
    return '$firstName شارك في $n أنشطة';
  }

  @override
  Widget build(BuildContext context) {
    final m = dayOverallMeta(day.overallEval);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            m.color.withValues(alpha: 0.14),
            m.color.withValues(alpha: 0.04),
          ],
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
                child: Icon(m.icon, size: 30, color: m.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تقييم اليوم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kJMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: m.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Line(
            icon: Icons.bolt_rounded,
            text: _activityLine,
            color: const Color(0xFF2563EB),
          ),
          if (day.photoCount > 0) ...[
            const SizedBox(height: 9),
            _Line(
              icon: Icons.photo_camera_rounded,
              text: '${day.photoCount} صورة من يومه',
              color: const Color(0xFF0EA5E9),
            ),
          ],
          const SizedBox(height: 9),
          _Line(
            icon: day.negativeNotes == 0
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            text: day.negativeNotes == 0
                ? 'لا توجد ملاحظات سلبية'
                : '${day.negativeNotes} ملاحظة تحتاج انتباه',
            color: day.negativeNotes == 0
                ? const Color(0xFF059669)
                : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, required this.color});
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
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: kJInk,
            ),
          ),
        ),
      ],
    );
  }
}
