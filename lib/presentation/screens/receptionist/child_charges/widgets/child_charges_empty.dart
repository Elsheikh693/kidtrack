import '../../../../../index/index_main.dart';

/// Shown when the nursery has no daily-expense charges yet.
class ChildChargesEmpty extends StatelessWidget {
  const ChildChargesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 42.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'daily_expense_empty_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'daily_expense_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.grayMedium),
            ),
          ),
        ],
      ),
    );
  }
}
