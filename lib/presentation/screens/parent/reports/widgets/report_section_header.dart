import '../../../../../index/index_main.dart';

/// Section label in the Reports hub — a short accent bar and a title that
/// groups related reports so the list reads as a clear hierarchy.
class ReportSectionHeader extends StatelessWidget {
  final String titleKey;
  final Color color;

  const ReportSectionHeader({
    super.key,
    required this.titleKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 24.h, 4.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 15.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            titleKey.tr,
            style: context.typography.smSemiBold
                .copyWith(color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}
