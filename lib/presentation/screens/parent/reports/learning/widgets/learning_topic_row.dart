import '../../../../../../index/index_main.dart';

/// One completed topic: title with a check, optional description, and the
/// teacher's note to parents when present.
class LearningTopicRow extends StatelessWidget {
  final LearningTopicItem topic;
  const LearningTopicRow({super.key, required this.topic});

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    final note = topic.note?.trim();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 16.sp, color: const Color(0xFF16A34A)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(topic.title,
                    style: context.typography.smMedium
                        .copyWith(color: const Color(0xFF334155))),
              ),
            ],
          ),
          if (note != null && note.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: 24.w, top: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _accent.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 13.sp, color: _accent),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('report_learning_teacher_note_label'.tr,
                            style: context.typography.xsMedium
                                .copyWith(color: _accent)),
                        SizedBox(height: 2.h),
                        Text(note,
                            style: context.typography.xsRegular.copyWith(
                                color: const Color(0xFF475569), height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
