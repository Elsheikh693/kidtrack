import '../../../../../index/index_main.dart';

class ScheduleEmptySection extends StatelessWidget {
  const ScheduleEmptySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.activityGreen.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.activityGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'schedule_empty_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.activitySlate),
          ),
          const SizedBox(height: 6),
          Text(
            'schedule_empty_subtitle'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.activityMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
