import '../../../../index/index_main.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSettingsTap;
  final bool? showNotificationDot;
  final bool showFilterIcon;

  const HomeAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onFilterTap,
    this.onSettingsTap,
    this.showNotificationDot,
    this.showFilterIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return AppBar(
      backgroundColor: AppColors.white,
      // Keep the bar pure white — without these, Material 3 tints the app bar
      // with a grey surface overlay once content scrolls beneath it.
      surfaceTintColor: AppColors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: true,
      toolbarHeight: 72.h,
      centerTitle: false,
      titleSpacing: 16.w,
      title: AppText(
        text: title,
        textStyle: typography.lgBold.copyWith(
          color: AppColors.backgroundBlack,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (showNotificationDot == null)
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onNotificationTap,
            child: SvgPicture.asset(
              IconsConstants.arrival,
              height: 32.h,
              width: 32.w,
            ),
          ),
        if (showFilterIcon) ...[
          SizedBox(width: 12.w),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onFilterTap,
            child: SvgPicture.asset(
              IconsConstants.filter,
              height: 27.h,
              width: 27.w,
            ),
          ),
        ],
        if (onSettingsTap != null) ...[
          SizedBox(width: 14.w),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: onSettingsTap,
            child: Icon(
              Icons.settings_outlined,
              size: 24.sp,
              color: const Color(0xFF374151),
            ),
          ),
        ],
        SizedBox(width: 20.w),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1.2,
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.25),
        ),
      ),
      shadowColor: AppColors.grayMedium,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72.h);
}
