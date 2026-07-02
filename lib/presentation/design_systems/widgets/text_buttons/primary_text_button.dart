import '../../../../index/index.dart';

class PrimaryTextButton extends AppTextButton {
  /// {@macro primary_text_button}
  const PrimaryTextButton({
    super.key,
    required super.label,
    super.onTap,
    super.elevation,
    super.leading,
    super.trailing,
    super.appButtonSize,
    this.customBackgroundColor,
    this.customDisabledColor,
    this.customFocusColor,
    this.customTextColor,
    this.customBorder,
  });

  /// Custom colors for the button
  final Color? customBackgroundColor;
  final Color? customDisabledColor;
  final Color? customFocusColor;
  final Color? customTextColor;

  /// Custom border for the button
  final BorderSide? customBorder;

  @override
  Color backgroundColor(BuildContext context) {
    return customBackgroundColor ?? context.buttonTheme.primaryButtonDefault;
  }

  @override
  Color disabledColor(BuildContext context) {
    return customDisabledColor ?? context.buttonTheme.buttonDisableColor;
  }

  @override
  Color focusColor(BuildContext context) {
    return customFocusColor ?? context.buttonTheme.primaryButtonFocused;
  }

  @override
  Color textColor(BuildContext context) {
    return customTextColor ?? context.buttonTheme.primaryTextButton;
  }

  @override
  BorderSide defaultBorder(BuildContext context) {
    return customBorder ?? BorderSide.none;
  }

  @override
  BorderSide focusedBorder(BuildContext context) {
    return customBorder ?? super.focusedBorder(context);
  }

  @override
  BorderSide hoverBorder(BuildContext context) {
    return customBorder ?? super.hoverBorder(context);
  }

  @override
  BorderSide disabledBorder(BuildContext context) {
    return customBorder ?? super.disabledBorder(context);
  }
}
