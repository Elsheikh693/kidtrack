import '../../../index/index.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.appButtonTheme,
    required this.appInputTheme,
    required this.appTypography,
    required this.appTextTheme,
    required this.appDropDownTheme,
    required this.appDatePickerTheme,
    required this.appBarTheme,
    required this.appCheckBoxTheme,
    required this.appListileTheme,
    required this.appToggleTheme,
  });

  factory AppTheme.light() {
    final colorMapping = ColorMappingImpl();
    return AppTheme(
      appButtonTheme: AppButtonTheme.fromColorMapping(colorMapping),
      appInputTheme: AppInputTheme.fromColorMapping(colorMapping),
      appTypography: AppTypography.light(),
      appTextTheme: AppTextTheme.light(),
      appDropDownTheme: AppDropdownTheme.light(),
      appDatePickerTheme: AppDatePickerTheme.light(),
      appBarTheme: AppBarThemeExtension.light(),
      appListileTheme: AppListTileThemeExtension.light(),
      appToggleTheme: AppToggleThemeExtension.light(),
      appCheckBoxTheme: AppCheckboxThemeExtension.light(),
    );
  }

  final ThemeExtension<AppButtonTheme> appButtonTheme;
  final ThemeExtension<AppInputTheme> appInputTheme;
  final ThemeExtension<AppTypography> appTypography;
  final ThemeExtension<AppTextTheme> appTextTheme;
  final ThemeExtension<AppDropdownTheme> appDropDownTheme;
  final ThemeExtension<AppDatePickerTheme> appDatePickerTheme;
  final ThemeExtension<AppBarThemeExtension> appBarTheme;
  final ThemeExtension<AppCheckboxThemeExtension> appCheckBoxTheme;
  final ThemeExtension<AppToggleThemeExtension> appToggleTheme;
  final ThemeExtension<AppListTileThemeExtension> appListileTheme;

  @override
  ThemeExtension<AppTheme> copyWith({
    ThemeExtension<AppButtonTheme>? appButtonTheme,
    ThemeExtension<AppInputTheme>? appInputTheme,
    ThemeExtension<AppTypography>? appTypography,
    ThemeExtension<AppTextTheme>? appTextTheme,
    ThemeExtension<AppDropdownTheme>? appDropDowntheme,
    ThemeExtension<AppDatePickerTheme>? appDatePickerTheme,
    ThemeExtension<AppBarThemeExtension>? appBarThemeExtension,
    ThemeExtension<AppCheckboxThemeExtension>? appCheckBoxTheme,
    ThemeExtension<AppToggleThemeExtension>? appToggleTheme,
    ThemeExtension<AppListTileThemeExtension>? appListileTheme,
  }) {
    return AppTheme(
      appButtonTheme: appButtonTheme ?? this.appButtonTheme,
      appInputTheme: appInputTheme ?? this.appInputTheme,
      appTypography: appTypography ?? this.appTypography,
      appTextTheme: appTextTheme ?? this.appTextTheme,
      appDropDownTheme: appDropDowntheme ?? appDropDownTheme,
      appDatePickerTheme: appDatePickerTheme ?? this.appDatePickerTheme,
      appBarTheme: appBarThemeExtension ?? appBarTheme,
      appCheckBoxTheme: appCheckBoxTheme ?? this.appCheckBoxTheme,
      appToggleTheme: appToggleTheme ?? this.appToggleTheme,
      appListileTheme: appListileTheme ?? this.appListileTheme,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(
    covariant ThemeExtension<AppTheme>? other,
    double t,
  ) {
    if (other is! AppTheme) {
      return this;
    }

    return AppTheme(
      appButtonTheme: appButtonTheme.lerp(other.appButtonTheme, t),
      appInputTheme: appInputTheme.lerp(other.appInputTheme, t),
      appTypography: appTypography.lerp(other.appTypography, t),
      appTextTheme: appTextTheme.lerp(other.appTextTheme, t),
      appDropDownTheme: appDropDownTheme.lerp(other.appDropDownTheme, t),
      appDatePickerTheme: appDatePickerTheme.lerp(other.appDatePickerTheme, t),
      appBarTheme: appBarTheme.lerp(other.appBarTheme, t),
      appListileTheme: appListileTheme.lerp(other.appListileTheme, t),
      appToggleTheme: appToggleTheme.lerp(other.appToggleTheme, t),
      appCheckBoxTheme: appCheckBoxTheme.lerp(other.appCheckBoxTheme, t),
    );
  }
}
