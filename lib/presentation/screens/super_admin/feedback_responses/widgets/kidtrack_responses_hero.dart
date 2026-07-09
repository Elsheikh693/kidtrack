import '../../../../../index/index_main.dart';
import '../kidtrack_feedback_responses_controller.dart';

/// Gradient summary hero for a KidTrack campaign's responses: average rating,
/// star distribution, total count, and a "share professional summary via
/// WhatsApp" action for the SuperAdmin.
class KidtrackResponsesHero extends StatelessWidget {
  const KidtrackResponsesHero({super.key, required this.controller});

  final KidtrackFeedbackResponsesController controller;

  @override
  Widget build(BuildContext context) {
    final avg = controller.averageRating;
    final dist = controller.distribution;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary80, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (controller.nurseryName.isNotEmpty) ...[
            Text(
              controller.nurseryName,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: context.typography.xxlBold
                        .copyWith(color: AppColors.white),
                  ),
                  _Stars(rating: avg.round()),
                  const SizedBox(height: 6),
                  Text(
                    'kidtrack_summary_responses'.tr,
                    style: context.typography.xsRegular.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85)),
                  ),
                  Text(
                    '${controller.totalCount}',
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (var star = 5; star >= 1; star--)
                      _DistRow(
                        star: star,
                        count: dist[star],
                        total: controller.totalCount,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: controller.shareSummaryToWhatsApp,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.18),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(
                'kidtrack_summary_share_btn'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _DistRow extends StatelessWidget {
  const _DistRow({required this.star, required this.count, required this.total});

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final white = AppColors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star.toString(),
              style: context.typography.xsMedium.copyWith(color: white)),
          const SizedBox(width: 4),
          Icon(Icons.star_rounded, size: 12, color: AppColors.ratingStar),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: white.withValues(alpha: 0.25),
                valueColor: AlwaysStoppedAnimation(AppColors.ratingStar),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              count.toString(),
              textAlign: TextAlign.end,
              style: context.typography.xsRegular
                  .copyWith(color: white.withValues(alpha: 0.85)),
            ),
          ),
        ],
      ),
    );
  }
}
