import '../../../../../index/index_main.dart';

/// Shared chrome for the child-management bottom sheets (change classroom /
/// package / branch): grab handle, header with an accent icon + title, and the
/// sheet body. Kept in one place so the three sheets stay small and identical
/// in look — the same rationale the design system uses for shared widgets.
class ManageSheetScaffold extends StatelessWidget {
  const ManageSheetScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 18.h),
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: context.typography.lgBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 6.h),
                Text(
                  subtitle!,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
              SizedBox(height: 18.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable option row used inside the management sheets.
class ManageSheetTile extends StatelessWidget {
  const ManageSheetTile({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grayLight,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.typography.smMedium.copyWith(
                  color: selected
                      ? AppColors.textDefault
                      : AppColors.textSecondaryParagraph,
                ),
              ),
            ),
            trailing ??
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondaryParagraph,
                  size: 22.sp,
                ),
          ],
        ),
      ),
    );
  }
}

/// Centered spinner shown while a sheet's lookup options load.
class ManageSheetLoader extends StatelessWidget {
  const ManageSheetLoader({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 36.h),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
}

/// Empty-state message for a sheet with no available options.
class ManageSheetEmpty extends StatelessWidget {
  const ManageSheetEmpty({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );
}

/// Opens [sheet] as a rounded white bottom sheet — the shared presentation for
/// all child-management sheets.
Future<void> showManageSheet(Widget sheet) {
  return Get.bottomSheet(
    sheet,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}
