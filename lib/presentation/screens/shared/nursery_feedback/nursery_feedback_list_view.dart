import '../../../../index/index_main.dart';
import 'widgets/feedback_share_card.dart';
import 'widgets/feedback_capture.dart';

/// Owner/Manager view of parent ratings: a gradient summary hero (average + star
/// breakdown) followed by each family's rating, comment and tags. Every review —
/// and the overall rating — can be shared as a branded KidTrack image.
class NurseryFeedbackListView extends StatefulWidget {
  const NurseryFeedbackListView({super.key});

  @override
  State<NurseryFeedbackListView> createState() =>
      _NurseryFeedbackListViewState();
}

class _NurseryFeedbackListViewState extends State<NurseryFeedbackListView> {
  late final NurseryFeedbackListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryFeedbackListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'nursery_feedback_view_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: controller.items.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _SummaryHero(controller: controller);
              return _FeedbackCard(item: controller.items[i - 1]);
            },
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reviews_outlined, size: 64, color: AppColors.grayMedium),
          const SizedBox(height: 16),
          Text(
            'nursery_feedback_empty'.tr,
            style: context.typography.mdRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

/// Rounded row of 5 stars filled up to [rating].
class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 18, this.color});

  final int rating;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: color ?? AppColors.ratingStar,
          size: size,
        ),
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.controller});

  final NurseryFeedbackListController controller;

  void _share() => captureAndShareFeedback(
        card: FeedbackSummaryShareCard(
          average: controller.averageRating,
          total: controller.totalCount,
        ),
        shareText: 'nursery_feedback_share_summary_text'.tr,
      );

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
                  _Stars(rating: avg.round(), size: 16, color: AppColors.white),
                  const SizedBox(height: 6),
                  Text(
                    'nursery_feedback_count'
                        .trParams({'count': controller.totalCount.toString()}),
                    style: context.typography.xsRegular.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85)),
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
              onPressed: _share,
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
                'nursery_feedback_share_overall'.tr,
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

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.item});

  final NurseryFeedbackModel item;

  String get _date {
    if (item.createdAt == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(item.createdAt!);
    return '${d.year}/${d.month}/${d.day}';
  }

  String get _initial {
    final t = item.parentName.trim();
    return t.isEmpty ? '؟' : t.characters.first;
  }

  void _share() => captureAndShareFeedback(
        card: FeedbackShareCard(item: item),
        shareText: 'nursery_feedback_share_review_text'.tr,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initial,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.parentName,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    Text(
                      _date,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _share,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.ios_share_rounded,
                    size: 18, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _Stars(rating: item.rating, size: 18),
          if ((item.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.comment!,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textPrimaryParagraph),
            ),
          ],
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.tr,
                          style: context.typography.xsMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
