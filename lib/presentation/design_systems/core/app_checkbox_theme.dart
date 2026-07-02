import 'dart:ui';
import '../../../index/index.dart';

class AppCheckboxThemeExtension
    extends ThemeExtension<AppCheckboxThemeExtension> {
  const AppCheckboxThemeExtension({
    required this.checkColor,
    required this.activeColor,
    required this.checkBoxShape,
    required this.focusColor,
    required this.hoverColor,
    required this.size,
    required this.checkedIcon,
    required this.uncheckedIcon,
    required this.splashColor,
    required this.overlayColor,
    required this.disabledColor,
    required this.enableFeedback,
    required this.visualDensity,
    required this.materialTapTargetSize,
    required this.shape, // Added shape property
    required this.mouseCursor, // Added mouseCursor property
    required this.side, // Added side property for checkbox border
  });

  /// The color of the check when the checkbox is checked.
  final Color checkColor;

  /// The color of the checkbox when it's in the active state.
  final Color activeColor;

  /// The shape of the checkbox (like circle or square).
  final ShapeBorder checkBoxShape;

  /// The color of the checkbox when focused.
  final Color focusColor;

  /// The color of the checkbox when hovered.
  final Color hoverColor;

  /// The size of the checkbox.
  final double size;

  /// Custom icon for the checked state.
  final Widget checkedIcon;

  /// Custom icon for the unchecked state.
  final Widget uncheckedIcon;

  /// The splash color when the checkbox is clicked.
  final Color splashColor;

  /// The color of the checkbox's overlay when pressed.
  final Color overlayColor;

  /// The color of the checkbox when it is disabled.
  final Color disabledColor;

  /// Whether the checkbox should provide visual feedback when clicked.
  final bool enableFeedback;

  /// The visual density of the checkbox.
  final VisualDensity visualDensity;

  /// The size of the tap target area for the checkbox.
  final MaterialTapTargetSize materialTapTargetSize;

  /// The shape of the checkbox (can be a custom shape such as circle, rounded, etc.).
  final OutlinedBorder shape;

  /// The mouse cursor to use when hovering over the checkbox (useful for web and desktop).
  final MouseCursor mouseCursor;

  /// The side property to define the border of the checkbox.
  final BorderSide side;

  /// A factory method to create a light theme for the checkbox.
  factory AppCheckboxThemeExtension.light() {
    return AppCheckboxThemeExtension(
      checkColor: Colors.white,
      activeColor: Colors.blue,
      checkBoxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      focusColor: Colors.blueAccent,
      hoverColor: Colors.blue.shade100,
      size: 24.0,
      checkedIcon: const Icon(Icons.check, color: Colors.blue),
      uncheckedIcon:
          const Icon(Icons.check_box_outline_blank, color: Colors.grey),
      splashColor: Colors.blue.withValues(alpha: 0.3),
      overlayColor: Colors.blue.withValues(alpha: 0.1),
      disabledColor: Colors.grey.shade400,
      enableFeedback: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      mouseCursor: SystemMouseCursors.click,
      // Corrected cursor
      side: const BorderSide(
          color: Colors.blue, width: 1.0), // Default border side
    );
  }

  /// A factory method to create a dark theme for the checkbox.
  factory AppCheckboxThemeExtension.dark() {
    return AppCheckboxThemeExtension(
      checkColor: Colors.black,
      activeColor: Colors.green,
      checkBoxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      focusColor: Colors.greenAccent,
      hoverColor: Colors.green.shade100,
      size: 24.0,
      checkedIcon: const Icon(Icons.check, color: Colors.green),
      uncheckedIcon:
          const Icon(Icons.check_box_outline_blank, color: Colors.grey),
      splashColor: Colors.green.withValues(alpha: 0.3),
      overlayColor: Colors.green.withValues(alpha: 0.1),
      disabledColor: Colors.grey.shade400,
      enableFeedback: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      mouseCursor: SystemMouseCursors.click,
      // Corrected cursor

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
          color: Colors.green, width: 1.0), // Default border side
    );
  }

  @override
  AppCheckboxThemeExtension copyWith({
    Color? checkColor,
    Color? activeColor,
    ShapeBorder? checkBoxShape,
    Color? focusColor,
    Color? hoverColor,
    double? size,
    Widget? checkedIcon,
    Widget? uncheckedIcon,
    Color? splashColor,
    Color? overlayColor,
    Color? disabledColor,
    bool? enableFeedback,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    ShapeBorder? shape,
    MouseCursor? mouseCursor,
    BorderSide? side,
  }) {
    return AppCheckboxThemeExtension(
      checkColor: checkColor ?? this.checkColor,
      activeColor: activeColor ?? this.activeColor,
      checkBoxShape: checkBoxShape ?? this.checkBoxShape,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      size: size ?? this.size,
      checkedIcon: checkedIcon ?? this.checkedIcon,
      uncheckedIcon: uncheckedIcon ?? this.uncheckedIcon,
      splashColor: splashColor ?? this.splashColor,
      overlayColor: overlayColor ?? this.overlayColor,
      disabledColor: disabledColor ?? this.disabledColor,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      visualDensity: visualDensity ?? this.visualDensity,
      materialTapTargetSize:
          materialTapTargetSize ?? this.materialTapTargetSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ) ,       mouseCursor: mouseCursor ?? this.mouseCursor,
      side: side ?? this.side,
    );
  }

  @override
  ThemeExtension<AppCheckboxThemeExtension> lerp(
    covariant ThemeExtension<AppCheckboxThemeExtension>? other,
    double t,
  ) {
    if (other is! AppCheckboxThemeExtension) {
      return this;
    }

    return AppCheckboxThemeExtension(
      checkColor: Color.lerp(checkColor, other.checkColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      checkBoxShape: checkBoxShape,
      focusColor: Color.lerp(focusColor, other.focusColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
      size: lerpDouble(size, other.size, t)!,
      checkedIcon: t < 0.5 ? checkedIcon : other.checkedIcon,
      uncheckedIcon: t < 0.5 ? uncheckedIcon : other.uncheckedIcon,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      enableFeedback: t < 0.5 ? enableFeedback : other.enableFeedback,
      visualDensity: t < 0.5 ? visualDensity : other.visualDensity,
      materialTapTargetSize:
          t < 0.5 ? materialTapTargetSize : other.materialTapTargetSize,
      shape: t < 0.5 ? shape : other.shape,
      mouseCursor: t < 0.5 ? mouseCursor : other.mouseCursor,
      side: t < 0.5 ? side : other.side,
    );
  }
}
