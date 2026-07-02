import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'activity_feed_tile.dart';

class DashboardActivityFeedSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const DashboardActivityFeedSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.activityItems;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'reception_activity_feed'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(checkInView),
                child: Text(
                  'common_view_all'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: const Color(0xFF0891B2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          if (items.isEmpty)
            _EmptyFeed()
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grayLight.withValues(alpha: 0.5),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 64.w,
                  color: AppColors.grayLight.withValues(alpha: 0.5),
                ),
                itemBuilder: (_, i) => ActivityFeedTile(record: items[i]),
              ),
            ),
        ],
      );
    });
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          'reception_activity_empty'.tr,
          style: context.typography.smRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
      ),
    );
  }
}
