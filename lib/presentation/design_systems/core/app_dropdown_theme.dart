import 'dart:ui';
import '../../../index/index.dart';


class AppDropdownTheme extends ThemeExtension<AppDropdownTheme> {
  const AppDropdownTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.hoverColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.textColor,
    required this.disabledTextColor,
    required this.disabledBackgroundColor,
    required this.iconColor,
    required this.disabledIconColor,
    required this.menuBackgroundColor,
    required this.menuBorderColor,
    required this.menuElevation,
    required this.menuPadding,
    required this.menuMaxHeight,
    required this.itemPadding,
    required this.itemHeight,
    required this.borderRadius,
    required this.borderWidth,
    required this.iconSize,
  });

  /// Light Theme Implementation
  factory AppDropdownTheme.light() {
    return AppDropdownTheme(
      backgroundColor: const Color(0xFFF8F8FA),
      borderColor: AppColors.grayLight,
      focusedBorderColor: AppColors.primary,
      hoverColor: const Color(0xFFF0F0F2),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grayMedium,
      textColor: AppColors.textDisplay,
      disabledTextColor: AppColors.grayLight,
      disabledBackgroundColor: const Color(0xFFF0F0F2),
      iconColor: AppColors.primary,
      disabledIconColor: AppColors.grayLight,
      menuBackgroundColor: Colors.white,
      menuBorderColor: AppColors.grayLight,
      menuElevation: 8.0,
      menuPadding: const EdgeInsets.all(8.0),
      menuMaxHeight: 300.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemHeight: 40.0,
      borderRadius: BorderRadius.circular(10.0),
      borderWidth: 1.0,
      iconSize: 24.0,
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color hoverColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color disabledBackgroundColor;
  final Color iconColor;
  final Color disabledIconColor;
  final Color menuBackgroundColor;
  final Color menuBorderColor;
  final double menuElevation;
  final EdgeInsetsGeometry menuPadding;
  final double menuMaxHeight;
  final EdgeInsetsGeometry itemPadding;
  final double itemHeight;
  final BorderRadiusGeometry borderRadius;
  final double borderWidth;
  final double iconSize;

  @override
  AppDropdownTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? hoverColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    Color? textColor,
    Color? disabledTextColor,
    Color? disabledBackgroundColor,
    Color? iconColor,
    Color? disabledIconColor,
    Color? menuBackgroundColor,
    Color? menuBorderColor,
    double? menuElevation,
    EdgeInsetsGeometry? menuPadding,
    double? menuMaxHeight,
    EdgeInsetsGeometry? itemPadding,
    double? itemHeight,
    BorderRadiusGeometry? borderRadius,
    double? borderWidth,
    double? iconSize,
  }) {
    return AppDropdownTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      hoverColor: hoverColor ?? this.hoverColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      menuBorderColor: menuBorderColor ?? this.menuBorderColor,
      menuElevation: menuElevation ?? this.menuElevation,
      menuPadding: menuPadding ?? this.menuPadding,
      menuMaxHeight: menuMaxHeight ?? this.menuMaxHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      itemHeight: itemHeight ?? this.itemHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  @override
  ThemeExtension<AppDropdownTheme> lerp(
      covariant ThemeExtension<AppDropdownTheme>? other, double t) {
    if (other is! AppDropdownTheme) return this;

    return AppDropdownTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      focusedBorderColor:
          Color.lerp(focusedBorderColor, other.focusedBorderColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
      selectedItemColor:
          Color.lerp(selectedItemColor, other.selectedItemColor, t)!,
      unselectedItemColor:
          Color.lerp(unselectedItemColor, other.unselectedItemColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      disabledTextColor:
          Color.lerp(disabledTextColor, other.disabledTextColor, t)!,
      disabledBackgroundColor: Color.lerp(
          disabledBackgroundColor, other.disabledBackgroundColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t)!,
      menuBackgroundColor:
          Color.lerp(menuBackgroundColor, other.menuBackgroundColor, t)!,
      menuBorderColor: Color.lerp(menuBorderColor, other.menuBorderColor, t)!,
      menuElevation: lerpDouble(menuElevation, other.menuElevation, t)!,
      menuPadding: EdgeInsetsGeometry.lerp(menuPadding, other.menuPadding, t)!,
      menuMaxHeight: lerpDouble(menuMaxHeight, other.menuMaxHeight, t)!,
      itemPadding: EdgeInsetsGeometry.lerp(itemPadding, other.itemPadding, t)!,
      itemHeight: lerpDouble(itemHeight, other.itemHeight, t)!,
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
    );
  }
}
