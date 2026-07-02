import 'dart:ui';
import '../../../index/index.dart';

class AppBarThemeExtension extends ThemeExtension<AppBarThemeExtension> {
  const AppBarThemeExtension({
    required this.titleTextColor,
    required this.titleTextStyle,
    required this.backgroundColor,
    required this.elevation,
    required this.iconColor,
    required this.actionsColor,
    required this.toolbarHeight,
    required this.centerTitle,
    required this.iconTheme,
    required this.leadingWidth,
    this.actions,
    this.leading,
    this.bottom,
    this.flexibleSpace,
    required this.titleSpacing,
    this.shape,
  });

  /// Light Theme Configuration
  factory AppBarThemeExtension.light() {
    return AppBarThemeExtension(
      titleTextColor: AppColors.primary,
      // Main black text
      titleTextStyle: TextStyle(
        color: AppColors.secondary80, // Gray natural color
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
      backgroundColor: AppColors.primary10,
      // Light background
      elevation: 4.0,
      // Shadow elevation
      iconColor: AppColors.primary,
      // Primary icon color
      actionsColor: AppColors.blueForeground,
      // Blue foreground for actions
      toolbarHeight: 56.0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColors.grayMedium, // Medium gray for icons
        size: 24.0,
      ),
      leadingWidth: 56.0,
      actions: [],
      leading: null,
      bottom: null,
      flexibleSpace: null,
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      shape: null,
    );
  }

  /// AppBar properties
  final Color titleTextColor;
  final TextStyle titleTextStyle;
  final Color backgroundColor;
  final double elevation;
  final Color iconColor;
  final Color actionsColor;
  final double toolbarHeight;
  final bool centerTitle;
  final IconThemeData iconTheme;
  final double leadingWidth;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final double titleSpacing;
  final ShapeBorder? shape;

  @override
  AppBarThemeExtension copyWith({
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    Color? backgroundColor,
    double? elevation,
    Color? iconColor,
    Color? actionsColor,
    double? toolbarHeight,
    bool? centerTitle,
    IconThemeData? iconTheme,
    double? leadingWidth,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom,
    Widget? flexibleSpace,
    double? titleSpacing,
    ShapeBorder? shape,
  }) {
    return AppBarThemeExtension(
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      iconColor: iconColor ?? this.iconColor,
      actionsColor: actionsColor ?? this.actionsColor,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      centerTitle: centerTitle ?? this.centerTitle,
      iconTheme: iconTheme ?? this.iconTheme,
      leadingWidth: leadingWidth ?? this.leadingWidth,
      actions: actions ?? this.actions,
      leading: leading ?? this.leading,
      bottom: bottom ?? this.bottom,
      flexibleSpace: flexibleSpace ?? this.flexibleSpace,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      shape: shape ?? this.shape,
    );
  }

  @override
  AppBarThemeExtension lerp(
    covariant ThemeExtension<AppBarThemeExtension>? other,
    double t,
  ) {
    if (other is! AppBarThemeExtension) return this;

    return AppBarThemeExtension(
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t)!,
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      actionsColor: Color.lerp(actionsColor, other.actionsColor, t)!,
      toolbarHeight: lerpDouble(toolbarHeight, other.toolbarHeight, t)!,
      centerTitle: t < 0.5 ? centerTitle : other.centerTitle,
      iconTheme: IconThemeData.lerp(iconTheme, other.iconTheme, t),
      leadingWidth: lerpDouble(leadingWidth, other.leadingWidth, t)!,
      actions: other.actions ?? actions,
      leading: other.leading ?? leading,
      bottom: other.bottom ?? bottom,
      flexibleSpace: other.flexibleSpace ?? flexibleSpace,
      titleSpacing: lerpDouble(titleSpacing, other.titleSpacing, t)!,
      shape: shape ?? other.shape,
    );
  }
}
