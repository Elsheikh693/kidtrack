import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'section_header.dart';

class DashboardPendingActionsSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const DashboardPendingActionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _PendingSkeleton();
      }
      final items = _buildItems(context);
      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: 'reception_pending_actions'.tr,
            accentColor: const Color(0xFFDC2626),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      );
    });
  }

  List<Widget> _buildItems(BuildContext context) {
    final items = <Widget>[];

    if (controller.pendingEnrollments.value > 0) {
      items.add(_PendingTile(
        icon: Icons.app_registration_rounded,
        color: const Color(0xFF0891B2),
        label: 'reception_pending_enrollments'.tr,
        count: controller.pendingEnrollments.value,
        onTap: () => Get.toNamed(enrollmentsView),
        isLast: false,
      ));
    }
    if (controller.pendingPickupRequests.value > 0) {
      items.add(_PendingTile(
        icon: Icons.directions_car_rounded,
        color: const Color(0xFF7C3AED),
        label: 'reception_pending_pickups'.tr,
        count: controller.pendingPickupRequests.value,
        onTap: () => Get.toNamed(pickupRequestsView),
        isLast: false,
      ));
    }
    if (controller.unassignedStudents.value > 0) {
      items.add(_PendingTile(
        icon: Icons.person_add_rounded,
        color: const Color(0xFFF97316),
        label: 'reception_pending_unassigned'.tr,
        count: controller.unassignedStudents.value,
        onTap: () => Get.toNamed(childrenView),
        isLast: false,
      ));
    }
    if (controller.overdueInvoices.value > 0) {
      items.add(_PendingTile(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
        label: 'reception_pending_overdue'.tr,
        count: controller.overdueInvoices.value,
        onTap: () => Get.toNamed(invoicesView),
        isLast: false,
      ));
    }
    if (controller.waitingListCount.value > 0) {
      items.add(_PendingTile(
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFF16A34A),
        label: 'reception_pending_waiting'.tr,
        count: controller.waitingListCount.value,
        onTap: () => Get.toNamed(waitingListView),
        isLast: false,
      ));
    }

    if (items.isNotEmpty) items.last = _rebuildLast(items.last);
    return items;
  }

  Widget _rebuildLast(Widget tile) {
    if (tile is _PendingTile) {
      return _PendingTile(
        icon: tile.icon,
        color: tile.color,
        label: tile.label,
        count: tile.count,
        onTap: tile.onTap,
        isLast: true,
      );
    }
    return tile;
  }
}

class _PendingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final VoidCallback onTap;
  final bool isLast;

  const _PendingTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.onTap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    count.toString(),
                    style: context.typography.xsMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios,
                    size: 13.sp, color: AppColors.grayMedium),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64.w,
            color: AppColors.grayLight.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _PendingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grayLight,
      highlightColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.w,
            height: 13.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: List.generate(3, (i) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Container(
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayLight,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 32.w,
                            height: 22.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayLight,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < 2)
                      Divider(
                        height: 1,
                        indent: 64.w,
                        color: AppColors.grayLight.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
