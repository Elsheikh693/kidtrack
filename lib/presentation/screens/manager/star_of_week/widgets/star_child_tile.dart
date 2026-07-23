import '../../../../../index/index_main.dart';
import '../star_of_week_controller.dart';

/// A selectable child row in the picker. Tapping toggles the selection; the
/// selected child gets a gold ring + check.
class StarChildTile extends StatelessWidget {
  const StarChildTile({
    super.key,
    required this.child,
    required this.controller,
  });

  final ChildModel child;
  final StarOfWeekController controller;

  static const _gold = Color(0xFFD9A400);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isSelected(child);
      return GestureDetector(
        onTap: () => controller.select(child),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 5.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected ? _gold : Colors.transparent,
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ChildAvatar(
                name: child.fullName,
                imageUrl: child.profileImage,
                size: 46.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                  text: child.fullName,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 16.sp, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
