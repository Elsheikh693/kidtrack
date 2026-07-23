import '../../../../../index/index_main.dart';

/// Reusable soft insight banner (icon + title + a gentle sentence), tinted by
/// [color]. Shared by every report.
class ReportInsightBanner extends StatelessWidget {
  final String text;
  final Color color;

  const ReportInsightBanner({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child:
                Icon(Icons.lightbulb_outline_rounded, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('report_insight_title'.tr,
                    style: context.typography.xsMedium.copyWith(color: color)),
                SizedBox(height: 4.h),
                Text(text,
                    style: context.typography.smRegular.copyWith(
                        height: 1.5, color: const Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
