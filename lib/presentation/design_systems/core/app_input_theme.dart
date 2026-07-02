import '../../../index/index.dart';

class AppInputTheme extends ThemeExtension<AppInputTheme> {
  /// Text Colors
  final Color labelTextColor;
  final Color hintTextColor;
  final Color focusedTextColor;
  final Color errorTextColor;
  final Color disabledTextColor;

  /// Border Colors
  final Color borderDefault;
  final Color borderFocused;
  final Color borderError;
  final Color borderDisabled;

  /// Background Colors
  final Color backgroundDefault;
  final Color backgroundFocused;
  final Color backgroundDisabled;

  /// Constructor
  const AppInputTheme({
    required this.labelTextColor,
    required this.hintTextColor,
    required this.focusedTextColor,
    required this.errorTextColor,
    required this.disabledTextColor,
    required this.borderDefault,
    required this.borderFocused,
    required this.borderError,
    required this.borderDisabled,
    required this.backgroundDefault,
    required this.backgroundFocused,
    required this.backgroundDisabled,
  });

  /// Factory method to create `AppInputTheme` from `ColorMapping`
  factory AppInputTheme.fromColorMapping(ColorMapping colorMapping) {
    return AppInputTheme(
      labelTextColor: colorMapping.labelTextColor,
      hintTextColor: colorMapping.hintTextColor,
      focusedTextColor: colorMapping.focusedTextColor,
      errorTextColor: colorMapping.errorTextColor,
      disabledTextColor: colorMapping.disabledTextColor,
      borderDefault: colorMapping.borderDefault,
      borderFocused: colorMapping.borderFocused,
      borderError: colorMapping.borderError,
      borderDisabled: colorMapping.borderDisabled,
      backgroundDefault: colorMapping.backgroundDefault,
      backgroundFocused: colorMapping.backgroundFocused,
      backgroundDisabled: colorMapping.backgroundDisabled,
    );
  }

  @override
  AppInputTheme copyWith({
    Color? labelTextColor,
    Color? hintTextColor,
    Color? focusedTextColor,
    Color? errorTextColor,
    Color? disabledTextColor,
    Color? borderDefault,
    Color? borderFocused,
    Color? borderError,
    Color? borderDisabled,
    Color? backgroundDefault,
    Color? backgroundFocused,
    Color? backgroundDisabled,
  }) {
    return AppInputTheme(
      labelTextColor: labelTextColor ?? this.labelTextColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      focusedTextColor: focusedTextColor ?? this.focusedTextColor,
      errorTextColor: errorTextColor ?? this.errorTextColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocused: borderFocused ?? this.borderFocused,
      borderError: borderError ?? this.borderError,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      backgroundDefault: backgroundDefault ?? this.backgroundDefault,
      backgroundFocused: backgroundFocused ?? this.backgroundFocused,
      backgroundDisabled: backgroundDisabled ?? this.backgroundDisabled,
    );
  }

  @override
  ThemeExtension<AppInputTheme> lerp(
    covariant ThemeExtension<AppInputTheme>? other,
    double t,
  ) {
    if (other is! AppInputTheme) return this;

    return AppInputTheme(
      labelTextColor: Color.lerp(labelTextColor, other.labelTextColor, t)!,
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t)!,
      focusedTextColor:
          Color.lerp(focusedTextColor, other.focusedTextColor, t)!,
      errorTextColor: Color.lerp(errorTextColor, other.errorTextColor, t)!,
      disabledTextColor:
          Color.lerp(disabledTextColor, other.disabledTextColor, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      borderError: Color.lerp(borderError, other.borderError, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      backgroundDefault:
          Color.lerp(backgroundDefault, other.backgroundDefault, t)!,
      backgroundFocused:
          Color.lerp(backgroundFocused, other.backgroundFocused, t)!,
      backgroundDisabled:
          Color.lerp(backgroundDisabled, other.backgroundDisabled, t)!,
    );
  }
}
