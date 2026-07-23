import '../../../../../index/index_main.dart';
import 'tutorial_roles.dart';

/// Multi-select chips for choosing which roles a tutorial video targets.
class RoleSelector extends StatelessWidget {
  final List<TutorialRole> roles;
  final Set<String> selected;
  final void Function(String name) onToggle;

  const RoleSelector({
    super.key,
    required this.roles,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: roles.map((r) {
        final isOn = selected.contains(r.name);
        return GestureDetector(
          onTap: () => onToggle(r.name),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isOn
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isOn ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOn) ...[
                  Icon(Icons.check_rounded, size: 15.sp, color: AppColors.white),
                  SizedBox(width: 4.w),
                ],
                AppText(
                  text: r.labelKey.tr,
                  textStyle: context.typography.xsMedium.copyWith(
                    color: isOn ? AppColors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
