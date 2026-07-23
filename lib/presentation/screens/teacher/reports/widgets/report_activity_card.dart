import '../../../../../index/index_main.dart';

Color _subjectColor(String? s) {
  if (s == null) return const Color(0xFF16A34A);
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return const Color(0xFF7C3AED);
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return const Color(0xFF2563EB);
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return const Color(0xFF059669);
  if (n.contains('علوم') || n.contains('science')) return const Color(0xFF0EA5E9);
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return const Color(0xFFD97706);
  if (n.contains('موسيق') || n.contains('music')) return const Color(0xFFEC4899);
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return const Color(0xFFF97316);
  return const Color(0xFF16A34A);
}

IconData _subjectIcon(String? s) {
  if (s == null) return Icons.auto_awesome_rounded;
  final n = s.toLowerCase();
  if (n.contains('رياضيات') || n.contains('حساب') || n.contains('math')) return Icons.calculate_rounded;
  if (n.contains('عرب') || n.contains('لغة') || n.contains('arabic')) return Icons.menu_book_rounded;
  if (n.contains('قرآن') || n.contains('دين') || n.contains('islam')) return Icons.auto_stories_rounded;
  if (n.contains('علوم') || n.contains('science')) return Icons.science_rounded;
  if (n.contains('فن') || n.contains('رسم') || n.contains('art')) return Icons.palette_rounded;
  if (n.contains('موسيق') || n.contains('music')) return Icons.music_note_rounded;
  if (n.contains('رياضة') || n.contains('sport') || n.contains('بدن')) return Icons.directions_run_rounded;
  return Icons.auto_awesome_rounded;
}

class ReportActivityCard extends StatelessWidget {
  const ReportActivityCard({
    super.key,
    required this.activity,
    required this.children,
    required this.onTap,
  });

  final ClassroomActivityModel activity;
  final List<ChildModel> children;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = activity.evaluations.length;
    final excellent = activity.evaluations.values.where((v) => v == 'excellent').length;
    final follow = activity.evaluations.values.where((v) => v == 'needs_follow').length;
    final attention = activity.evaluations.values.where((v) => v == 'needs_attention').length;
    final participated = activity.childIds.length;
    final evalPct = participated == 0 ? 0 : ((total / participated) * 100).round();

    final startDt = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final timeLabel =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';

    final color = _subjectColor(activity.subjectName);
    final icon = _subjectIcon(activity.subjectName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar — first child = right side in RTL
                Container(width: 5, color: color),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: context.typography.smSemiBold.copyWith(
                                      color: const Color(0xFF111827),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (activity.subjectName != null) ...[
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        activity.subjectName!,
                                        style: context.typography.xsMedium.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Time + elapsed chips
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _MetaChip(label: timeLabel, color: const Color(0xFF64748B), bg: const Color(0xFFF1F5F9)),
                                const SizedBox(height: 5),
                                _MetaChip(label: activity.elapsedLabel, color: color, bg: color.withValues(alpha: 0.08)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(height: 1, color: const Color(0xFFF3F4F6)),

                      // ── Bottom row ───────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_rounded,
                                      size: 12, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$participated',
                                    style: context.typography.xsMedium.copyWith(
                                      color: const Color(0xFF475569),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (excellent > 0) ...[
                              _EvalDot(count: excellent, color: const Color(0xFF16A34A)),
                              const SizedBox(width: 6),
                            ],
                            if (follow > 0) ...[
                              _EvalDot(count: follow, color: const Color(0xFFD97706)),
                              const SizedBox(width: 6),
                            ],
                            if (attention > 0) ...[
                              _EvalDot(count: attention, color: const Color(0xFFDC2626)),
                              const SizedBox(width: 6),
                            ],
                            const Spacer(),
                            if (participated > 0) ...[
                              Text(
                                '$evalPct%',
                                style: context.typography.xsMedium.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}

class _EvalDot extends StatelessWidget {
  const _EvalDot({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      );
}
