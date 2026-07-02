import '../../../index/index.dart';

class AppDatePickerTheme extends ThemeExtension<AppDatePickerTheme> {
  const AppDatePickerTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.selectedDateColor,
    required this.disabledDateColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.borderColor,
    required this.borderRadius,
    required this.padding,
  });

  /// Light Theme Implementation
  factory AppDatePickerTheme.light() {
    return AppDatePickerTheme(
      backgroundColor: AppColors.primary10,
      textColor: AppColors.textDisplay,
      selectedDateColor: AppColors.primary,
      disabledDateColor: AppColors.grayLight,
      buttonColor: AppColors.primary,
      buttonTextColor: AppColors.white,
      borderColor: AppColors.grayLight,
      borderRadius: BorderRadius.circular(10.0),
      padding: const EdgeInsets.all(8.0),
    );
  }

  final Color backgroundColor;
  final Color textColor;
  final Color selectedDateColor;
  final Color disabledDateColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color borderColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  AppDatePickerTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? selectedDateColor,
    Color? disabledDateColor,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return AppDatePickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      selectedDateColor: selectedDateColor ?? this.selectedDateColor,
      disabledDateColor: disabledDateColor ?? this.disabledDateColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  @override
  ThemeExtension<AppDatePickerTheme> lerp(
      covariant ThemeExtension<AppDatePickerTheme>? other, double t) {
    if (other is! AppDatePickerTheme) return this;

    return AppDatePickerTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      selectedDateColor:
          Color.lerp(selectedDateColor, other.selectedDateColor, t)!,
      disabledDateColor:
          Color.lerp(disabledDateColor, other.disabledDateColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
    );
  }
}
