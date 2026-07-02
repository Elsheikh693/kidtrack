import '../../../../../index/index_main.dart';

class DirectionSelector extends StatelessWidget {
  const DirectionSelector({super.key, required this.controller});
  final ChaperoneHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.direction.value;
      final locked = controller.isTracking.value;
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            _Segment(
              label: 'tracking_dir_to_home'.tr,
              icon: Icons.home_rounded,
              selected: current == BusTripDirection.toHome,
              locked: locked,
              onTap: () => controller.setDirection(BusTripDirection.toHome),
            ),
            _Segment(
              label: 'tracking_dir_to_nursery'.tr,
              icon: Icons.school_rounded,
              selected: current == BusTripDirection.toNursery,
              locked: locked,
              onTap: () => controller.setDirection(BusTripDirection.toNursery),
            ),
          ],
        ),
      );
    });
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.locked,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: locked ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.sp,
                color: selected ? color : AppColors.grayMedium,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: context.typography.smMedium.copyWith(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : AppColors.grayMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
