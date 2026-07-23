import '../../../../../../index/index_main.dart';

/// One child in the manager review list: avatar, name, workflow-status chip and
/// score. Tapping opens the read-only result (where publish/lock/unlock live).
class ManagerChildStatusTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final ChildAssessmentModel row;
  final VoidCallback onTap;

  const ManagerChildStatusTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.row,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = row.officialAttempt?.percentage;
    final (label, color) = _status();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ChildAvatar(name: name, imageUrl: imageUrl, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? '—' : name,
                        style: context.typography.smSemiBold
                            .copyWith(color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label,
                          style: context.typography.xsMedium
                              .copyWith(color: color)),
                    ),
                  ],
                ),
              ),
              if (pct != null)
                Text('${pct.round()}%',
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_outlined,
                  size: 13, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _status() {
    switch (row.status) {
      case kChildStatusTeacherCompleted:
        return ('assessment_child_completed'.tr, const Color(0xFFD97706));
      case kChildStatusReviewed:
        return ('assessment_child_reviewed'.tr, const Color(0xFF0891B2));
      case kChildStatusPublished:
        return ('assessment_child_published'.tr, const Color(0xFF16A34A));
      case kChildStatusLocked:
        return ('assessment_child_locked'.tr, const Color(0xFF6366F1));
      default:
        return ('assessment_child_in_progress'.tr, const Color(0xFF94A3B8));
    }
  }
}
