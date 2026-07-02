import '../../../../../index/index_main.dart';

/// KidTrack wordmark used to brand shared images.
class _Brand extends StatelessWidget {
  const _Brand({this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? AppColors.white : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: onDark
                ? AppColors.white.withValues(alpha: 0.20)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.child_care_rounded, color: fg, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          'KidTrack',
          style: context.typography.smSemiBold
              .copyWith(color: fg, fontFamilyFallback: const []),
        ),
      ],
    );
  }
}

class _ShareStars extends StatelessWidget {
  const _ShareStars({required this.rating, this.size = 28});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.ratingStar,
          size: size,
        ),
      ),
    );
  }
}

String _initial(String name) {
  final t = name.trim();
  return t.isEmpty ? '؟' : t.characters.first;
}

/// Branded testimonial image for a single parent review.
class FeedbackShareCard extends StatelessWidget {
  const FeedbackShareCard({super.key, required this.item});

  final NurseryFeedbackModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary80, AppColors.primary, AppColors.primary60],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.centerRight, child: const _Brand(onDark: true)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.format_quote_rounded,
                    color: AppColors.primary.withValues(alpha: 0.25), size: 40),
                const SizedBox(height: 6),
                _ShareStars(rating: item.rating),
                const SizedBox(height: 16),
                Text(
                  (item.comment ?? '').trim().isEmpty
                      ? 'nursery_feedback_default_praise'.tr
                      : item.comment!.trim(),
                  textAlign: TextAlign.center,
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.textDefault, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        _initial(item.parentName),
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.parentName,
                          style: context.typography.smSemiBold
                              .copyWith(color: AppColors.textDefault),
                        ),
                        Text(
                          'nursery_feedback_parent_role'.tr,
                          style: context.typography.xsRegular
                              .copyWith(color: AppColors.textSecondaryParagraph),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'nursery_feedback_brand_tagline'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// Branded image for the nursery's overall rating.
class FeedbackSummaryShareCard extends StatelessWidget {
  const FeedbackSummaryShareCard({
    super.key,
    required this.average,
    required this.total,
  });

  final double average;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary80, AppColors.primary, AppColors.primary60],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: Alignment.centerRight, child: const _Brand(onDark: true)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'nursery_feedback_summary_share_title'.tr,
                  style: context.typography.smMedium
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
                const SizedBox(height: 10),
                Text(
                  average.toStringAsFixed(1),
                  style: context.typography.xxlBold.copyWith(
                    color: AppColors.textDefault,
                    fontSize: 64,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                _ShareStars(rating: average.round(), size: 32),
                const SizedBox(height: 12),
                Text(
                  'nursery_feedback_count'.trParams({'count': total.toString()}),
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'nursery_feedback_brand_tagline'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
