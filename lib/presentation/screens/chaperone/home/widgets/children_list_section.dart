import '../../../../../index/index_main.dart';
import 'child_pickup_card.dart';

class ChildrenListSection extends StatelessWidget {
  const ChildrenListSection({super.key, required this.controller});
  final ChaperoneHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingChildren.value) {
        return Padding(
          padding: EdgeInsets.all(32.w),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.children.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(32.w),
          child: Center(
            child: Text(
              'tracking_no_children'.tr,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
        );
      }

      final isTracking = controller.isTracking.value;

      // Sort: pending first, then onBus, then delivered
      final sorted = [...controller.children]
        ..sort((a, b) => a.status.index.compareTo(b.status.index));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Text(
                  'tracking_children_list'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${controller.children.length}',
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sorted.map((c) => ChildPickupCard(
                child: c,
                controller: controller,
                isTracking: isTracking,
              )),
          SizedBox(height: 16.h),
        ],
      );
    });
  }
}
