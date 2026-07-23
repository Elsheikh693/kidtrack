import '../../../../../index/index_main.dart';
import '../media_approval_controller.dart';
import '../media_approval_view.dart';

/// Home banner that surfaces when activity photos are waiting for review. Shown
/// only to users who may review (owner / branch manager / granted staff) and
/// only while there is something pending — it is the reviewer's "N photos
/// waiting" nudge. Tapping opens the media-approval list.
class MediaApprovalBanner extends StatelessWidget {
  const MediaApprovalBanner({super.key});

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    if (!SessionService().canReviewPhotos) return const SizedBox.shrink();
    final controller = Get.find<MediaApprovalController>();
    return Obx(() {
      final count = controller.totalPendingPhotos;
      if (count <= 0) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: GestureDetector(
          onTap: () => Get.to(() => const MediaApprovalView()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rate_review_rounded,
                      color: _accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'media_banner_pending'.trParams({'count': '$count'}),
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _accent, size: 24),
              ],
            ),
          ),
        ),
      );
    });
  }
}
