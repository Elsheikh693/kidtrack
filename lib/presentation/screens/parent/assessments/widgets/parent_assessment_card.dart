import '../../../../../index/index_main.dart';

/// One published assessment in the parent's list: title, subject/date, the
/// child's score, and a retake hint if one is scheduled.
class ParentAssessmentCard extends StatelessWidget {
  final ChildAssessmentModel row;
  final AssessmentRunModel run;
  final VoidCallback onTap;

  const ParentAssessmentCard({
    super.key,
    required this.row,
    required this.run,
    required this.onTap,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final pct = row.officialAttempt?.percentage;
    final scoreColor = _colorForPct(pct);
    final start = DateTime.fromMillisecondsSinceEpoch(run.startDate);
    final date =
        '${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pct == null ? '—' : '${pct.round()}%',
                  style: context.typography.smSemiBold
                      .copyWith(color: scoreColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(run.title,
                        style: context.typography.smSemiBold
                            .copyWith(color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (run.subject != null && run.subject!.isNotEmpty)
                          run.subject!,
                        date,
                      ].join(' • '),
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                    if (row.hasPendingRetake) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_repeat_rounded,
                              size: 13, color: Color(0xFFB45309)),
                          const SizedBox(width: 4),
                          Text('assessment_retake_pending'.tr,
                              style: context.typography.xsMedium
                                  .copyWith(color: const Color(0xFFB45309))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_outlined,
                  size: 13, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForPct(double? pct) {
    if (pct == null) return _accent;
    if (pct >= 75) return const Color(0xFF16A34A);
    if (pct >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}
