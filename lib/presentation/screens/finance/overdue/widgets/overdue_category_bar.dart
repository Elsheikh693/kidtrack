import '../../../../../index/index_main.dart';

class OverdueCategoryBar extends StatelessWidget {
  final OverdueController controller;

  const OverdueCategoryBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          children: [
            _chip(
              context,
              label: 'overdue_category_all'.tr,
              active: controller.selectedCategoryId.value == null,
              color: AppColors.primary,
              onTap: () => controller.setCategory(null),
            ),
            ...controller.categories.map(
              (c) => _chip(
                context,
                label: c.name,
                active: controller.selectedCategoryId.value == c.id,
                color: Color(c.colorValue),
                onTap: () => controller.setCategory(c.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: active ? color : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              margin: EdgeInsets.only(left: 6.w),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: active ? color : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
