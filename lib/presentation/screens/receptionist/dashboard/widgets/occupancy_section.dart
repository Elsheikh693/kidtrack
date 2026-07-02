import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'occupancy_card.dart';
import 'section_header.dart';

class DashboardOccupancySection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const DashboardOccupancySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _OccupancySkeleton();
      }
      final items = controller.classOccupancy;
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: 'reception_class_occupancy'.tr,
            accentColor: const Color(0xFF16A34A),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 112.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) => OccupancyCard(data: items[i]),
            ),
          ),
        ],
      );
    });
  }
}

class _OccupancySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 112.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, __) => Container(
                width: 120.w,
                height: 112.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
