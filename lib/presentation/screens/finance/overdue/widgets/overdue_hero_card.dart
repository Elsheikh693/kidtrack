import '../../../../../index/index_main.dart';

class OverdueHeroCard extends StatelessWidget {
  final double total;
  final int overdueCount;
  final double upcomingTotal;

  const OverdueHeroCard({
    super.key,
    required this.total,
    required this.overdueCount,
    required this.upcomingTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary80, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'overdue_total_label'.tr,
                style: context.typography.smMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '${total.toStringAsFixed(0)} ${'overdue_currency'.tr}',
            style: context.typography.xxlBold.copyWith(color: Colors.white),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'overdue_stat_overdue'.tr,
                  value: '$overdueCount',
                ),
              ),
              Container(
                width: 1,
                height: 32.h,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _Stat(
                  label: 'overdue_stat_upcoming'.tr,
                  value:
                      '${upcomingTotal.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.typography.lgBold.copyWith(color: Colors.white),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: context.typography.xsRegular.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
