import '../../../../../index/index_main.dart';

const _ink = Color(0xFF111827);
const _faint = Color(0xFFAEB6C4);

class RcStatusFilter extends StatelessWidget {
  final ChildListController controller;
  const RcStatusFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 6.h),
      child: Obx(
        () => Row(
          children: [
            _Tab(
              label: 'child_filter_all'.tr,
              count: controller.totalCount,
              selected: controller.statusFilter.value == 'all',
              onTap: () => controller.setStatus('all'),
            ),
            SizedBox(width: 18.w),
            _Tab(
              label: 'child_status_active'.tr,
              count: controller.activeCount,
              selected: controller.statusFilter.value == 'active',
              onTap: () => controller.setStatus('active'),
            ),
            SizedBox(width: 18.w),
            _Tab(
              label: 'child_status_inactive'.tr,
              count: controller.inactiveCount,
              selected: controller.statusFilter.value == 'inactive',
              onTap: () => controller.setStatus('inactive'),
            ),
          ],
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
