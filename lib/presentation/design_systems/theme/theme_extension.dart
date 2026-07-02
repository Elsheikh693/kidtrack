
import '../../../index/index.dart';

extension ThemeExt on BuildContext {
  /// The current theme.
  ThemeData get theme => Theme.of(this);

  ///the current button theme
  AppButtonTheme get buttonTheme =>
      theme.extension<AppTheme>()!.appButtonTheme as AppButtonTheme;

  /// The current app typography.
  AppTypography get typography =>
      theme.extension<AppTheme>()!.appTypography as AppTypography;

  AppInputTheme get inputTheme =>
      theme.extension<AppTheme>()!.appInputTheme as AppInputTheme;

  AppTextTheme get appTextTheme =>
      theme.extension<AppTheme>()!.appTextTheme as AppTextTheme;

  AppDropdownTheme get appDropdownTheme =>
      theme.extension<AppTheme>()!.appDropDownTheme as AppDropdownTheme;

  AppBarThemeExtension get appBarTheme =>
      theme.extension<AppTheme>()!.appBarTheme as AppBarThemeExtension;

  AppCheckboxThemeExtension get appCheckBoxTheme =>
      theme.extension<AppTheme>()!.appCheckBoxTheme
          as AppCheckboxThemeExtension;

  AppToggleThemeExtension get appToggleTheme =>
      theme.extension<AppTheme>()!.appToggleTheme as AppToggleThemeExtension;

  AppListTileThemeExtension get appListileTheme =>
      theme.extension<AppTheme>()!.appListileTheme as AppListTileThemeExtension;

  AppDatePickerTheme get appDatePickerTheme =>
      theme.extension<AppTheme>()!.appDatePickerTheme as AppDatePickerTheme;

// /// The current app checkboxTheme.
// AppCheckboxTheme get checkboxTheme =>
//     theme.extension<AppTheme>()!.appCheckboxTheme as AppCheckboxTheme;
//
// /// The current app iconTheme.
// AppIconTheme get iconTheme =>
//     theme.extension<AppTheme>()!.appIconTheme as AppIconTheme;

// /// The current app radioTheme.
// AppRadioTheme get radioTheme =>
//     theme.extension<AppTheme>()!.appRadioTheme as AppRadioTheme;
//
// /// The current app toggleTheme.
// AppToggleTheme get toggleTheme =>
//     theme.extension<AppTheme>()!.appToggleTheme as AppToggleTheme;
//
// /// The current app typographyTheme.
// AppTypographyTheme get typographyTheme =>
//     theme.extension<AppTheme>()!.appTypographyTheme as AppTypographyTheme;
//
// /// The current app avatarTheme.
// AppAvatarTheme get avatarTheme =>
//     theme.extension<AppTheme>()!.appAvatarTheme as AppAvatarTheme;
//
// /// The current app navigationTheme.
// AppNavigationTheme get navigationTheme =>
//     theme.extension<AppTheme>()!.appNavigationTheme as AppNavigationTheme;
//
// /// The current app layoutTheme.
// AppLayoutTheme get layoutTheme =>
//     theme.extension<AppTheme>()!.appLayoutTheme as AppLayoutTheme;
//
// /// The current app badgeTheme.
// AppBadgeTheme get badgeTheme =>
//     theme.extension<AppTheme>()!.appBadgeTheme as AppBadgeTheme;
//
// /// The current app breadcrumbTheme.
// AppBreadCrumbTheme get appBreadCrumbTheme =>
//     theme.extension<AppTheme>()!.appBreadCrumbTheme as AppBreadCrumbTheme;
//
}
