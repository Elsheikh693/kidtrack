import '../../../../../../index/index_main.dart';

/// One assessment run in the manager hub: title, status, class/date meta, and
/// contextual actions (publish a draft, open an active run, delete).
class AssessmentRunCard extends StatelessWidget {
  final AssessmentRunModel run;
  final String classesLabel;
  final VoidCallback onPublish;

  /// Open the run's detail (review). Null until the review screen exists.
  final VoidCallback? onOpen;
  final VoidCallback onDelete;

  const AssessmentRunCard({
    super.key,
    required this.run,
    required this.classesLabel,
    required this.onPublish,
    this.onOpen,
    required this.onDelete,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: run.isDraft ? null : onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      run.title,
                      style: context.typography.smSemiBold
                          .copyWith(color: const Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusChip(context),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (run.subject != null && run.subject!.isNotEmpty)
                    run.subject!,
                  if (classesLabel.isNotEmpty) classesLabel,
                  '${run.items.length} ${'assessment_items_unit'.tr}',
                ].join(' • '),
                style: context.typography.xsRegular
                    .copyWith(color: const Color(0xFF94A3B8)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (run.isDraft)
                    _actionButton(
                      context,
                      icon: Icons.publish_rounded,
                      label: 'assessment_run_publish'.tr,
                      color: _accent,
                      filled: true,
                      onTap: onPublish,
                    )
                  else if (onOpen != null)
                    _actionButton(
                      context,
                      icon: Icons.grading_rounded,
                      label: 'assessment_run_open'.tr,
                      color: _accent,
                      filled: false,
                      onTap: onOpen!,
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626), size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    late final Color c;
    late final String key;
    if (run.isDraft) {
      c = const Color(0xFF94A3B8);
      key = 'assessment_status_draft';
    } else if (run.isActive) {
      c = const Color(0xFF16A34A);
      key = 'assessment_status_active';
    } else {
      c = const Color(0xFF0891B2);
      key = 'assessment_status_completed';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(key.tr,
          style: context.typography.smSemiBold.copyWith(color: c)),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label,
                style: context.typography.smSemiBold
                    .copyWith(color: filled ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}
