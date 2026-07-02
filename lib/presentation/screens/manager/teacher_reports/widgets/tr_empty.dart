import '../../../../../index/index_main.dart';

/// Shown when no completed activities exist in the selected span.
class TrEmpty extends StatelessWidget {
  const TrEmpty({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 32.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.10),
            ),
            child: Icon(Icons.bar_chart_rounded, size: 46.sp, color: accent),
          ),
          SizedBox(height: 18.h),
          Text(
            'tr_empty_title'.tr,
            textAlign: TextAlign.center,
            style: context.typography.mdBold.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'tr_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: context.typography.xsMedium.copyWith(
              fontSize: 13,
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
