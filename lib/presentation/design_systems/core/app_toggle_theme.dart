import 'dart:ui';
import '../../../index/index.dart';

/*
activeColor: The color of the toggle when it is in the "on" (active) state.
inactiveColor: The color of the toggle when it is in the "off" (inactive) state.
trackColor: The color of the background track of the toggle.
thumbColor: The color of the circular thumb of the toggle.
size: The size (width and height) of the toggle widget.
splashColor: The splash color when the toggle is pressed, giving it a ripple effect.
overlayColor: The color of the overlay when the toggle is pressed.
iconSize: The size of the icons that will appear inside the toggle when it is on or off.
checkedIcon: The custom icon that will appear when the toggle is in the "on" state.
uncheckedIcon: The custom icon that will appear when the toggle is in the "off" state.
borderRadius: The border radius for the toggle's corners.
autofocus: Whether the toggle should automatically gain focus when displayed.
 */

class AppToggleThemeExtension extends ThemeExtension<AppToggleThemeExtension> {
  const AppToggleThemeExtension({
    required this.activeColor,
    required this.inactiveColor,
    required this.trackColor,
    required this.thumbColor,
    required this.size,
    required this.splashColor,
    required this.overlayColor,
    required this.iconSize,
    required this.checkedIcon,
    required this.uncheckedIcon,
    required this.borderRadius,
    required this.autofocus,
  });

  /// The color of the toggle when it's active (on state).
  final Color activeColor;

  /// The color of the toggle when it's inactive (off state).
  final Color inactiveColor;

  /// The color of the track when the toggle is active or inactive.
  final Color trackColor;

  /// The color of the thumb (circle) part of the toggle.
  final Color thumbColor;

  /// The size of the toggle widget (width and height).
  final double size;

  /// The splash color when the toggle is clicked.
  final Color splashColor;

  /// The overlay color when the toggle is pressed.
  final Color overlayColor;

  /// The size of the icons on the toggle (if you use custom icons).
  final double iconSize;

  /// The icon to display when the toggle is on.
  final Widget checkedIcon;

  /// The icon to display when the toggle is off.
  final Widget uncheckedIcon;

  /// The border radius for the toggle's corners.
  final BorderRadiusGeometry borderRadius;

  /// Whether the toggle should automatically gain focus when displayed.
  final bool autofocus;

  /// A factory method to create a light theme for the toggle.
  factory AppToggleThemeExtension.light() {
    return AppToggleThemeExtension(
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      trackColor: Colors.blue.shade100,
      thumbColor: Colors.white,
      size: 40.0,
      splashColor: Colors.blue.withValues(alpha: 0.3),
      overlayColor: Colors.blue.withValues(alpha: 0.1),
      iconSize: 20.0,
      checkedIcon: const Icon(Icons.check, color: Colors.white),
      uncheckedIcon: const Icon(Icons.close, color: Colors.white),
      borderRadius: BorderRadius.circular(8.0),
      autofocus: false,
    );
  }

  /// A factory method to create a dark theme for the toggle.
  factory AppToggleThemeExtension.dark() {
    return AppToggleThemeExtension(
      activeColor: Colors.green,
      inactiveColor: Colors.grey,
      trackColor: Colors.green.shade100,
      thumbColor: Colors.white,
      size: 40.0,
      splashColor: Colors.green.withValues(alpha: 0.3),
      overlayColor: Colors.green.withValues(alpha: 0.1),
      iconSize: 20.0,
      checkedIcon: const Icon(Icons.check, color: Colors.white),
      uncheckedIcon: const Icon(Icons.close, color: Colors.white),
      borderRadius: BorderRadius.circular(8.0),
      autofocus: false,
    );
  }

  @override
  AppToggleThemeExtension copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? trackColor,
    Color? thumbColor,
    double? size,
    Color? splashColor,
    Color? overlayColor,
    double? iconSize,
    Widget? checkedIcon,
    Widget? uncheckedIcon,
    BorderRadiusGeometry? borderRadius,
    bool? autofocus,
  }) {
    return AppToggleThemeExtension(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      trackColor: trackColor ?? this.trackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      size: size ?? this.size,
      splashColor: splashColor ?? this.splashColor,
      overlayColor: overlayColor ?? this.overlayColor,
      iconSize: iconSize ?? this.iconSize,
      checkedIcon: checkedIcon ?? this.checkedIcon,
      uncheckedIcon: uncheckedIcon ?? this.uncheckedIcon,
      borderRadius: borderRadius ?? this.borderRadius,
      autofocus: autofocus ?? this.autofocus,
    );
  }

  @override
  ThemeExtension<AppToggleThemeExtension> lerp(
    covariant ThemeExtension<AppToggleThemeExtension>? other,
    double t,
  ) {
    if (other is! AppToggleThemeExtension) {
      return this;
    }

    return AppToggleThemeExtension(
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      trackColor: Color.lerp(trackColor, other.trackColor, t)!,
      thumbColor: Color.lerp(thumbColor, other.thumbColor, t)!,
      size: lerpDouble(size, other.size, t)!,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      checkedIcon: t < 0.5 ? checkedIcon : other.checkedIcon,
      uncheckedIcon: t < 0.5 ? uncheckedIcon : other.uncheckedIcon,
      borderRadius: BorderRadius.lerp(
          borderRadius as BorderRadius, other.borderRadius as BorderRadius, t)!,
      autofocus: t < 0.5 ? autofocus : other.autofocus,
    );
  }
}
