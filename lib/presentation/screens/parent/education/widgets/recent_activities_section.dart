import '../../../../../index/index_main.dart';
import '../controller.dart';

class RecentActivitiesSection extends StatelessWidget {
  const RecentActivitiesSection({super.key, required this.activities});

  final List<LearningActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'parent_edu_no_activities'.tr,
          style: context.typography.smRegular.copyWith(color: AppColors.textSecondaryParagraph),
        ),
      );
    }
    return Column(
      children: activities
          .asMap()
          .entries
          .map((e) => _ActivityRow(activity: e.value, isLast: e.key == activities.length - 1))
          .toList(),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.isLast});

  final LearningActivity activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // time column
          SizedBox(
            width: 44,
            child: Text(
              activity.time,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          // timeline line + dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.subjectKey.tr,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.title,
                    style: context.typography.smMedium.copyWith(
                      color: AppColors.textDefault,
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
