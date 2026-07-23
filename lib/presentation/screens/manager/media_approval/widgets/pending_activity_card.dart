import '../../../../../index/index_main.dart';

/// One row in the media-approval list: an activity whose photos are awaiting
/// review. Tapping "Review" opens the per-activity grid.
class PendingActivityCard extends StatelessWidget {
  const PendingActivityCard({
    super.key,
    required this.activity,
    required this.classroomName,
    required this.onReview,
  });

  final ClassroomActivityModel activity;
  final String classroomName;
  final VoidCallback onReview;

  static const _accent = Color(0xFF0891B2);

  String get _title => (activity.subjectName?.isNotEmpty == true)
      ? activity.subjectName!
      : activity.title;

  String get _time {
    final d = DateTime.fromMillisecondsSinceEpoch(activity.startedAt);
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: _accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (classroomName.isNotEmpty) classroomName,
                    _time,
                    'media_pending_count'.trParams({
                      'count': '${activity.pendingPhotoCount}',
                    }),
                  ].join(' · '),
                  style: context.typography.xsRegular.copyWith(
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'media_review_action'.tr,
                style: context.typography.xsMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
