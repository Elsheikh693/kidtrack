import '../../../../../index/index_main.dart';

class ParentSectionHeader extends StatelessWidget {
  const ParentSectionHeader({
    super.key,
    required this.titleKey,
    this.onViewAll,
    this.viewAllKey = 'parent_requests_view_all',
    this.largeViewAll = false,
  });

  final String titleKey;
  final VoidCallback? onViewAll;
  final String viewAllKey;
  final bool largeViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titleKey.tr,
              style: context.typography.smSemiBold.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                viewAllKey.tr,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: largeViewAll ? 14 : null,
                  decoration:
                      largeViewAll ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: largeViewAll ? AppColors.primary : null,
                  decorationThickness: largeViewAll ? 1.5 : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
