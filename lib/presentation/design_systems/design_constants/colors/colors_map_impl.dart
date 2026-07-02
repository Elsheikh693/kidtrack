import '../../../../index/index.dart';

class ColorMappingImpl implements ColorMapping {
  @override
  Color get labelTextColor => AppColors.textFieldPlaceholder;

  @override
  Color get hintTextColor => AppColors.textFieldPlaceholder;

  @override
  Color get focusedTextColor => AppColors.formFieldTextLabel;

  @override
  Color get errorTextColor => AppColors.errorForeground;

  @override
  Color get disabledTextColor => AppColors.grayMedium;

  @override
  Color get borderDefault => AppColors.textFieldBorderDefault;

  @override
  Color get borderFocused => AppColors.textFieldBorderFocused;

  @override
  Color get borderError => AppColors.errorForeground;

  @override
  Color get borderDisabled => AppColors.grayLight;

  @override
  Color get backgroundDefault => AppColors.white;

  @override
  Color get backgroundFocused => AppColors.textFieldBackgroundFocused;

  @override
  Color get backgroundDisabled => AppColors.grayLight;

  // Button Colors
  @override
  Color get primaryButtonDefault => AppColors.primary;

  @override
  Color get primaryButtonFocused => AppColors.buttonpressedColor;

  @override
  Color get primaryButtonEnabled => AppColors.primary;

  @override
  Color get primaryTextButton => AppColors.white;

  @override
  Color get buttonDisableColor => AppColors.buttonDisabledColor;

  @override
  Color get buttonDisabledTextColor => AppColors.buttonDisabledTextColor;

  @override
  Color get secondaryButtonText => AppColors.primary;

  @override
  Color get secondaryButtonDefault => AppColors.secondary10;

  @override
  Color get secondaryButtonHover => AppColors.secondary20;

  @override
  Color get secondaryButtonFocused => AppColors.secondary40;

  @override
  Color get secondaryButtonEnabled => AppColors.primary80;

  @override
  Color get outlineButtonText => AppColors.primary;

  @override
  Color get outlineButtonDefault => AppColors.primary.withValues(alpha: 0.4);

  @override
  Color get outlineButtonHover => AppColors.primary.withValues(alpha: 0.6);

  @override
  Color get outlineButtonFocused => AppColors.primary.withValues(alpha: 0.8);

  @override
  Color get outlineButtonEnabled => AppColors.primary.withValues(alpha: 0.2);

  @override
  Color get borderNeutralPrimary => AppColors.borderNeutralPrimary;

  // New Colors
  @override
  Color get textDisplay => AppColors.textDisplay;

  @override
  Color get textSecondaryParagraph => AppColors.textSecondaryParagraph;

  @override
  Color get textLabel => AppColors.formFieldTextLabel;

  @override
  Color get white => AppColors.white;

  @override
  Color get textDefault => AppColors.textDefault;

  @override
  Color get backgroundBlackDefault => AppColors.backgroundBlackDefault;

  @override
  Color get backgroundErrorLight => AppColors.backgroundErrorLight;

  @override
  Color get backgroundNeutralDefault => AppColors.backgroundNeutralDefault;

  @override
  Color get backgroundWarningLight => AppColors.backgroundWarningLight;

  @override
  Color get tagIconWarning => AppColors.tagIconWarning;

  @override
  Color get tagTextError => AppColors.tagTextError;

  @override
  Color get backgroundNeutral100 => AppColors.backgroundNeutral100;

  @override
  Color get fieldTextPlaceholder => AppColors.fieldTextPlaceholder;
}
