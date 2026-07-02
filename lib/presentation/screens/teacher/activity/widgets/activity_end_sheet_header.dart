import '../../../../../index/index_main.dart';

class ActivityEndSheetHeader extends StatelessWidget {
  const ActivityEndSheetHeader({
    super.key,
    required this.activityTitle,
    this.classroomName = '',
    this.childrenCount = 0,
  });
  final String activityTitle;
  final String classroomName;
  final int childrenCount;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (classroomName.isNotEmpty) classroomName,
      if (childrenCount > 0) '$childrenCount ${'teacher_end_children_word'.tr}',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.activityRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.stop_circle_rounded,
              color: AppColors.activityRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityTitle,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDisplay),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
