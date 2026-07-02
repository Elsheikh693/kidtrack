import '../../../index/index.dart';

class AppButtonTheme extends ThemeExtension<AppButtonTheme> {
  const AppButtonTheme({
    required this.primaryButtonDefault,
    required this.primaryButtonFocused,
    required this.primaryButtonEnabled,
    required this.primaryTextButton,
    required this.buttonDisableColor,
    required this.buttonDisabledTextColor,
    required this.secondaryButtonText,
    required this.secondaryButtonDefault,
    required this.secondaryButtonHover,
    required this.secondaryButtonFocused,
    required this.secondaryButtonEnabled,
    required this.outlineButtonText,
    required this.outlineButtonDefault,
    required this.outlineButtonHover,
    required this.outlineButtonFocused,
    required this.outlineButtonEnabled,
  });

  /// Factory method to create `AppButtonTheme` from `ColorMapping`
  factory AppButtonTheme.fromColorMapping(ColorMapping colorMapping) {
    return AppButtonTheme(
      primaryButtonDefault: colorMapping.primaryButtonDefault,
      primaryButtonFocused: colorMapping.primaryButtonFocused,
      primaryButtonEnabled: colorMapping.primaryButtonEnabled,
      primaryTextButton: colorMapping.primaryTextButton,
      buttonDisableColor: colorMapping.buttonDisableColor,
      buttonDisabledTextColor: colorMapping.buttonDisabledTextColor,
      secondaryButtonText: colorMapping.secondaryButtonText,
      secondaryButtonDefault: colorMapping.secondaryButtonDefault,
      secondaryButtonHover: colorMapping.secondaryButtonHover,
      secondaryButtonFocused: colorMapping.secondaryButtonFocused,
      secondaryButtonEnabled: colorMapping.secondaryButtonEnabled,
      outlineButtonText: colorMapping.outlineButtonText,
      outlineButtonDefault: colorMapping.outlineButtonDefault,
      outlineButtonHover: colorMapping.outlineButtonHover,
      outlineButtonFocused: colorMapping.outlineButtonFocused,
      outlineButtonEnabled: colorMapping.outlineButtonEnabled,
    );
  }

  final Color primaryButtonDefault;
  final Color primaryButtonFocused;
  final Color primaryButtonEnabled;
  final Color primaryTextButton;

  final Color buttonDisableColor;
  final Color buttonDisabledTextColor;

  final Color secondaryButtonText;
  final Color secondaryButtonDefault;
  final Color secondaryButtonHover;
  final Color secondaryButtonFocused;
  final Color secondaryButtonEnabled;

  final Color outlineButtonText;
  final Color outlineButtonDefault;
  final Color outlineButtonHover;
  final Color outlineButtonFocused;
  final Color outlineButtonEnabled;

  @override
  ThemeExtension<AppButtonTheme> copyWith({
    Color? primaryButtonDefault,
    Color? primaryButtonFocused,
    Color? primaryButtonEnabled,
    Color? primaryTextButton,
    Color? buttonDisableColor,
    Color? buttonDisabledTextColor,
    Color? secondaryButtonText,
    Color? secondaryButtonDefault,
    Color? secondaryButtonHover,
    Color? secondaryButtonFocused,
    Color? secondaryButtonEnabled,
    Color? outlineButtonText,
    Color? outlineButtonDefault,
    Color? outlineButtonHover,
    Color? outlineButtonFocused,
    Color? outlineButtonEnabled,
  }) {
    return AppButtonTheme(
      primaryButtonDefault: primaryButtonDefault ?? this.primaryButtonDefault,
      primaryButtonFocused: primaryButtonFocused ?? this.primaryButtonFocused,
      primaryButtonEnabled: primaryButtonEnabled ?? this.primaryButtonEnabled,
      primaryTextButton: primaryTextButton ?? this.primaryTextButton,
      buttonDisableColor: buttonDisableColor ?? this.buttonDisableColor,
      buttonDisabledTextColor:
          buttonDisabledTextColor ?? this.buttonDisabledTextColor,
      secondaryButtonText: secondaryButtonText ?? this.secondaryButtonText,
      secondaryButtonDefault:
          secondaryButtonDefault ?? this.secondaryButtonDefault,
      secondaryButtonHover: secondaryButtonHover ?? this.secondaryButtonHover,
      secondaryButtonFocused:
          secondaryButtonFocused ?? this.secondaryButtonFocused,
      secondaryButtonEnabled:
          secondaryButtonEnabled ?? this.secondaryButtonEnabled,
      outlineButtonText: outlineButtonText ?? this.outlineButtonText,
      outlineButtonDefault: outlineButtonDefault ?? this.outlineButtonDefault,
      outlineButtonHover: outlineButtonHover ?? this.outlineButtonHover,
      outlineButtonFocused: outlineButtonFocused ?? this.outlineButtonFocused,
      outlineButtonEnabled: outlineButtonEnabled ?? this.outlineButtonEnabled,
    );
  }

  @override
  ThemeExtension<AppButtonTheme> lerp(
      covariant ThemeExtension<AppButtonTheme>? other, double t) {
    if (other is! AppButtonTheme) return this;

    return AppButtonTheme(
      primaryButtonDefault:
          Color.lerp(primaryButtonDefault, other.primaryButtonDefault, t)!,
      primaryButtonFocused:
          Color.lerp(primaryButtonFocused, other.primaryButtonFocused, t)!,
      primaryButtonEnabled:
          Color.lerp(primaryButtonEnabled, other.primaryButtonEnabled, t)!,
      primaryTextButton:
          Color.lerp(primaryTextButton, other.primaryTextButton, t)!,
      buttonDisableColor:
          Color.lerp(buttonDisableColor, other.buttonDisableColor, t)!,
      buttonDisabledTextColor: Color.lerp(
          buttonDisabledTextColor, other.buttonDisabledTextColor, t)!,
      secondaryButtonText:
          Color.lerp(secondaryButtonText, other.secondaryButtonText, t)!,
      secondaryButtonDefault:
          Color.lerp(secondaryButtonDefault, other.secondaryButtonDefault, t)!,
      secondaryButtonHover:
          Color.lerp(secondaryButtonHover, other.secondaryButtonHover, t)!,
      secondaryButtonFocused:
          Color.lerp(secondaryButtonFocused, other.secondaryButtonFocused, t)!,
      secondaryButtonEnabled:
          Color.lerp(secondaryButtonEnabled, other.secondaryButtonEnabled, t)!,
      outlineButtonText:
          Color.lerp(outlineButtonText, other.outlineButtonText, t)!,
      outlineButtonDefault:
          Color.lerp(outlineButtonDefault, other.outlineButtonDefault, t)!,
      outlineButtonHover:
          Color.lerp(outlineButtonHover, other.outlineButtonHover, t)!,
      outlineButtonFocused:
          Color.lerp(outlineButtonFocused, other.outlineButtonFocused, t)!,
      outlineButtonEnabled:
          Color.lerp(outlineButtonEnabled, other.outlineButtonEnabled, t)!,
    );
  }
}
