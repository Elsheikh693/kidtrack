import '../../../../../index/index_main.dart';

class OverdueEmpty extends StatelessWidget {
  const OverdueEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded,
                size: 44.sp, color: AppColors.successForeground),
          ),
          SizedBox(height: 16.h),
          Text(
            'overdue_empty_title'.tr,
            style: context.typography.mdBold
                .copyWith(color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 6.h),
          Text(
            'overdue_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smRegular
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
