import '../../../../../../index/index_main.dart';

const _ink = Color(0xFF111827);
const _faint = Color(0xFFAEB6C4);

/// Status tabs mirroring the children-tab filter style: All / Not sent /
/// Awaiting / Activated. `null` filter = All.
class BulkInviteFilterBar extends StatelessWidget {
  final BulkInvitationsController controller;
  const BulkInviteFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18.w, 2.h, 18.w, 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _Tab(
                label: 'rc_bulk_invite_filter_all'.tr,
                count: controller.totalCount,
                selected: controller.statusFilter.value == null,
                onTap: () => controller.setStatusFilter(null),
              ),
              SizedBox(width: 18.w),
              _Tab(
                label: 'rc_bulk_invite_filter_not_sent'.tr,
                count: controller.notSentCount,
                selected: controller.statusFilter.value ==
                    ParentOnboardingStatus.notSent,
                onTap: () => controller
                    .setStatusFilter(ParentOnboardingStatus.notSent),
              ),
              SizedBox(width: 18.w),
              _Tab(
                label: 'rc_bulk_invite_filter_sent'.tr,
                count: controller.sentCount,
                selected: controller.statusFilter.value ==
                    ParentOnboardingStatus.sent,
                onTap: () =>
                    controller.setStatusFilter(ParentOnboardingStatus.sent),
              ),
              SizedBox(width: 18.w),
              _Tab(
                label: 'rc_bulk_invite_filter_activated'.tr,
                count: controller.activatedCount,
                selected: controller.statusFilter.value ==
                    ParentOnboardingStatus.activated,
                onTap: () => controller
                    .setStatusFilter(ParentOnboardingStatus.activated),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label · $count',
            style: context.typography.displaySmBold.copyWith(
              fontSize: 13.5,
              color: selected ? _ink : _faint,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: 22.w,
            height: 2.5.h,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
