import 'dart:ui';
import '../../../index/index.dart';

class AppListTileThemeExtension
    extends ThemeExtension<AppListTileThemeExtension> {
  const AppListTileThemeExtension({
    required this.tileColor,
    required this.selectedTileColor,
    required this.textStyle,
    required this.iconSize,
    required this.iconColor,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTapColor,
    required this.subtitleStyle,
    required this.dense,
    required this.shape,
    required this.selected,
    required this.focusColor,
    required this.hoverColor,
    required this.contentPadding,
    required this.horizontalTitleGap,
    required this.minVerticalPadding,
    required this.mouseCursor,
  });

  final Color tileColor;
  final Color selectedTileColor;
  final TextStyle textStyle;
  final double iconSize;
  final Color iconColor;
  final Widget leadingIcon;
  final Widget trailingIcon;
  final Color onTapColor;
  final TextStyle subtitleStyle;
  final bool dense;
  final bool selected;
  final Color focusColor;
  final Color hoverColor;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry contentPadding;
  final double horizontalTitleGap;
  final double minVerticalPadding;
  final MouseCursor mouseCursor;

  factory AppListTileThemeExtension.light() {
    return AppListTileThemeExtension(
      tileColor: AppColors.primary, // Replace with updated light background
      selectedTileColor: AppColors.blueForeground, // Selected tile light green
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      iconSize: 24.0,
      iconColor: AppColors.blueForeground, // Blue for icons
      leadingIcon: const Icon(Icons.star, color: Color(0xFF4CAF50)), // Green icon
      trailingIcon: const Icon(Icons.arrow_back, color: Color(0xFFCCCCCC)),
      onTapColor: AppColors.yellowBackground, // Yellow light background
      subtitleStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
      dense: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selected: false,
      focusColor: AppColors.primary, // Dark green focus color
      hoverColor: AppColors.blueForeground, // Light green hover color
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      horizontalTitleGap: 16.0,
      minVerticalPadding: 8.0,
      mouseCursor: SystemMouseCursors.click,
    );
  }



  @override
  AppListTileThemeExtension copyWith({
    Color? tileColor,
    Color? selectedTileColor,
    TextStyle? textStyle,
    double? iconSize,
    Color? iconColor,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Color? onTapColor,
    TextStyle? subtitleStyle,
    bool? dense,
    bool? selected,
    Color? focusColor,
    OutlinedBorder? shape,
    Color? hoverColor,
    EdgeInsetsGeometry? contentPadding,
    double? horizontalTitleGap,
    double? minVerticalPadding,
    MouseCursor? mouseCursor,
  }) {
    return AppListTileThemeExtension(
      tileColor: tileColor ?? this.tileColor,
      shape: shape ?? this.shape,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      textStyle: textStyle ?? this.textStyle,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      leadingIcon: leadingIcon ?? this.leadingIcon,
      trailingIcon: trailingIcon ?? this.trailingIcon,
      onTapColor: onTapColor ?? this.onTapColor,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      dense: dense ?? this.dense,
      selected: selected ?? this.selected,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      contentPadding: contentPadding ?? this.contentPadding,
      horizontalTitleGap: horizontalTitleGap ?? this.horizontalTitleGap,
      minVerticalPadding: minVerticalPadding ?? this.minVerticalPadding,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  @override
  ThemeExtension<AppListTileThemeExtension> lerp(
      covariant ThemeExtension<AppListTileThemeExtension>? other,
      double t,
      ) {
    if (other is! AppListTileThemeExtension) {
      return this;
    }

    return AppListTileThemeExtension(
      tileColor: Color.lerp(tileColor, other.tileColor, t)!,
      shape: t < 0.5 ? shape : other.shape,
      selectedTileColor:
      Color.lerp(selectedTileColor, other.selectedTileColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      leadingIcon: t < 0.5 ? leadingIcon : other.leadingIcon,
      trailingIcon: t < 0.5 ? trailingIcon : other.trailingIcon,
      onTapColor: Color.lerp(onTapColor, other.onTapColor, t)!,
      subtitleStyle:
      TextStyle.lerp(subtitleStyle, other.subtitleStyle, t) ?? textStyle,
      dense: t < 0.5 ? dense : other.dense,
      selected: t < 0.5 ? selected : other.selected,
      focusColor: Color.lerp(focusColor, other.focusColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
      contentPadding:
      EdgeInsetsGeometry.lerp(contentPadding, other.contentPadding, t) ??
          EdgeInsets.zero,
      horizontalTitleGap:
      lerpDouble(horizontalTitleGap, other.horizontalTitleGap, t)!,
      minVerticalPadding:
      lerpDouble(minVerticalPadding, other.minVerticalPadding, t)!,
      mouseCursor: t < 0.5 ? mouseCursor : other.mouseCursor,
    );
  }
}
