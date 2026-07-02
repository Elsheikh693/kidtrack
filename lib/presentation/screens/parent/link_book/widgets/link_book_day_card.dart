import 'package:flutter/material.dart';
import '../../education/widgets/journal_meta.dart';
import '../link_book_controller.dart';

/// A single "page" of the Link Book — one day, summarised at a glance.
class LinkBookDayCard extends StatelessWidget {
  const LinkBookDayCard({super.key, required this.day, required this.onTap});

  final LinkBookDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = dayOverallMeta(day.overallEval);
    final subjects = day.subjects.take(2).toList();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kJBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── eval header band ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    m.color.withValues(alpha: 0.16),
                    m.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: m.color.withValues(alpha: 0.25)),
                    ),
                    child: Icon(m.icon, size: 19, color: m.color),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journalDateLabel(day.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kJInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: m.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── body ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.auto_awesome_rounded,
                        value: day.activityCount,
                        color: const Color(0xFF2563EB),
                      ),
                      if (day.photoCount > 0) ...[
                        const SizedBox(width: 8),
                        _Stat(
                          icon: Icons.photo_camera_rounded,
                          value: day.photoCount,
                          color: const Color(0xFF0EA5E9),
                        ),
                      ],
                      if (day.notes.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _Stat(
                          icon: Icons.sticky_note_2_rounded,
                          value: day.notes.length,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ],
                  ),
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in subjects) _SubjectChip(name: s),
                        if (day.subjects.length > 2)
                          _SubjectChip(name: '+${day.subjects.length - 2}'),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 11),
                    Text(
                      'ملاحظات المعلمة',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: kJMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.color});
  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final color = journalSubjectColor(name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
