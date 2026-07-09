import '../../../../../index/index_main.dart';

class KidtrackResponseCard extends StatelessWidget {
  final KidtrackFeedbackResponseModel item;
  const KidtrackResponseCard({super.key, required this.item});

  String get _date {
    if (item.createdAt == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(item.createdAt!);
    return '${d.year}/${d.month}/${d.day}';
  }

  String get _initial {
    final t = item.parentName.trim();
    return t.isEmpty ? '؟' : t.characters.first;
  }

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
              _Stars(rating: item.rating),
            ],
          ),
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
                          t,
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
          color: AppColors.ratingStar,
          size: 16,
        ),
      ),
    );
  }
}
