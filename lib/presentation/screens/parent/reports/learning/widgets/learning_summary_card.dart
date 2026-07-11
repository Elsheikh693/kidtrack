import '../../../../../../index/index_main.dart';

/// Hero card: how many topics were covered across how many subjects this week.
class LearningSummaryCard extends StatelessWidget {
  final WeeklyLearningController controller;
  const LearningSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _Metric(
              value: controller.topicsCount.value,
              labelKey: 'report_learning_topics',
              color: const Color(0xFF0891B2),
              icon: Icons.menu_book_rounded,
            ),
            Container(width: 1, height: 44.h, color: const Color(0xFFE2E8F0)),
            _Metric(
              value: controller.subjectsCount.value,
              labelKey: 'report_learning_subjects',
              color: const Color(0xFF7C3AED),
              icon: Icons.category_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final int value;
  final String labelKey;
  final Color color;
  final IconData icon;
  const _Metric({
    required this.value,
    required this.labelKey,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text('$value',
              style: context.typography.xxlBold.copyWith(color: color)),
          SizedBox(height: 2.h),
          Text(labelKey.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
