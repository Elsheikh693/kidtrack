import '../../../../../index/index_main.dart';

/// One row in the media-approval list: a nursery event whose photos are awaiting
/// review. Tapping "Review" opens the per-event grid.
class PendingEventCard extends StatelessWidget {
  const PendingEventCard({
    super.key,
    required this.event,
    required this.onReview,
  });

  final NurseryEventModel event;
  final VoidCallback onReview;

  static const _accent = Color(0xFF6366F1);

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
            child: Icon(event.category.icon, color: _accent, size: 22.sp),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    event.formattedDate,
                    'media_pending_count'
                        .trParams({'count': '${event.pendingPhotoCount}'}),
                  ].join(' · '),
                  style: context.typography.xsRegular
                      .copyWith(color: Colors.grey.shade500),
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
                style:
                    context.typography.xsMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
