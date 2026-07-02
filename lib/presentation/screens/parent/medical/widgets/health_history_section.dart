import '../../../../../index/index_main.dart';

class HealthHistorySection extends StatelessWidget {
  const HealthHistorySection({super.key, required this.controller});

  final ParentMedicalController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'parent_med_history_title'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (controller.healthHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'parent_med_history_empty'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ),
            )
          else
            ...List.generate(controller.healthHistory.length, (i) {
              final event = controller.healthHistory[i];
              final isLast = i == controller.healthHistory.length - 1;
              return _HistoryEventTile(event: event, isLast: isLast);
            }),
        ],
      ),
    );
  }
}

class _HistoryEventTile extends StatelessWidget {
  const _HistoryEventTile({required this.event, required this.isLast});

  final HealthHistoryEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(event.icon, color: event.color, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: context.typography.smSemiBold
                              .copyWith(color: AppColors.textDefault),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.dateTime,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
