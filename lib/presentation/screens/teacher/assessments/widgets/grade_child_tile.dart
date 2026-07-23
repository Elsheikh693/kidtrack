import '../../../../../index/index_main.dart';

/// One child in a run's grading list: avatar, name, and a status/score badge.
class GradeChildTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final ChildAssessmentModel row;
  final VoidCallback onTap;

  const GradeChildTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.row,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final graded = row.status != kChildStatusInProgress;
    final pct = row.officialAttempt?.percentage;
    final retakeDue = row.hasPendingRetake;
    // Teacher may grade a fresh row, one still in review, or a scheduled retake
    // — but not a published/locked result (that's the manager's to reopen).
    final editable = retakeDue ||
        row.status == kChildStatusInProgress ||
        row.status == kChildStatusTeacherCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: editable ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ChildAvatar(name: name, imageUrl: imageUrl, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name.isEmpty ? '—' : name,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (retakeDue)
                _badge(context, 'assessment_retake_due'.tr,
                    const Color(0xFFB45309))
              else if (graded && pct != null)
                _badge(context, '${pct.round()}%', const Color(0xFF16A34A))
              else
                _badge(context, 'assessment_grade_pending'.tr,
                    const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Icon(
                retakeDue
                    ? Icons.event_repeat_rounded
                    : graded
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_outlined,
                color: retakeDue
                    ? const Color(0xFFB45309)
                    : graded
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: context.typography.smSemiBold.copyWith(color: c)),
    );
  }
}
