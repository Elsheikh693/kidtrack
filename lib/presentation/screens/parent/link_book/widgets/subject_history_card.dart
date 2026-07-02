import 'package:flutter/material.dart';
import '../../education/widgets/journal_meta.dart';
import '../link_book_controller.dart';

/// A subject's at-a-glance card in the "by subject" view of the Link Book:
/// icon + name, activity/photo counts, the latest evaluation, and a mini trend.
class SubjectHistoryCard extends StatelessWidget {
  const SubjectHistoryCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  final SubjectHistory subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = journalSubjectColor(subject.name);
    final icon = journalEventIcon(subject.name);
    final latest = subject.latestEval;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.20)),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kJInk,
                          ),
                        ),
                      ),
                      if (subject.trend != null) _TrendPill(trend: subject.trend!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetaBit(
                        icon: Icons.auto_awesome_rounded,
                        text: '${subject.activityCount} نشاط',
                        color: const Color(0xFF2563EB),
                      ),
                      if (subject.photoCount > 0) ...[
                        const SizedBox(width: 8),
                        _MetaBit(
                          icon: Icons.photo_camera_rounded,
                          text: '${subject.photoCount}',
                          color: const Color(0xFF0EA5E9),
                        ),
                      ],
                      const Spacer(),
                      if (latest != null) _EvalDot(level: latest),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: kJMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.trend});
  final String trend;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String label) = switch (trend) {
      'up' => (Icons.trending_up_rounded, const Color(0xFF059669), 'تطور'),
      'down' => (Icons.trending_down_rounded, const Color(0xFFD97706), 'تراجع'),
      _ => (Icons.trending_flat_rounded, const Color(0xFF64748B), 'ثابت'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBit extends StatelessWidget {
  const _MetaBit({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kJMuted,
          ),
        ),
      ],
    );
  }
}

class _EvalDot extends StatelessWidget {
  const _EvalDot({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final m = evalChipMeta(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: m.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(m.icon, size: 12, color: m.color),
          const SizedBox(width: 4),
          Text(
            m.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: m.color,
            ),
          ),
        ],
      ),
    );
  }
}
