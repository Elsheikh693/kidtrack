import '../../../../../index/index_main.dart';

/// A run the teacher can grade, with a graded/total progress bar.
class TeacherAssessmentRunCard extends StatelessWidget {
  final AssessmentRunModel run;
  final int graded;
  final int total;
  final VoidCallback onTap;

  const TeacherAssessmentRunCard({
    super.key,
    required this.run,
    required this.graded,
    required this.total,
    required this.onTap,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : graded / total;
    final done = total > 0 && graded >= total;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grading_rounded,
                        color: _accent, size: 22),
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
                            '${run.items.length} ${'assessment_items_unit'.tr}',
                          ].join(' • '),
                          style: context.typography.xsRegular
                              .copyWith(color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_outlined,
                      size: 13, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEEF2FF),
                  valueColor: AlwaysStoppedAnimation(
                    done ? const Color(0xFF16A34A) : _accent,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'assessment_grade_progress'.trParams(
                    {'done': '$graded', 'total': '$total'}),
                style: context.typography.xsMedium.copyWith(
                    color: done
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
