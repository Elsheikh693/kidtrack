import '../../../../../../index/index_main.dart';

/// One subject with the list of topics covered under it this week.
class LearningSubjectCard extends StatelessWidget {
  final LearningSubjectGroup group;
  const LearningSubjectCard({super.key, required this.group});

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.menu_book_rounded, color: _accent, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(group.subjectName,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('${group.topics.length}',
                    style: context.typography.xsBold.copyWith(color: _accent)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          for (final topic in group.topics)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16.sp, color: const Color(0xFF16A34A)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(topic,
                        style: context.typography.smRegular
                            .copyWith(color: const Color(0xFF475569))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
