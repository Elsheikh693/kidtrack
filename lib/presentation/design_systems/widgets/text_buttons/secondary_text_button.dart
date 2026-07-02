import '../../../../index/index.dart';

class SecondaryTextButton extends AppTextButton {
  /// {@macro secondary_text_button}
  const SecondaryTextButton({
    super.key,
    required super.label,
    super.onTap,
    super.leading,
    super.trailing,
    super.appButtonSize,
  });

  @override
  Color backgroundColor(BuildContext context) {
    return context.buttonTheme.secondaryButtonDefault;
  }

  @override
  Color disabledColor(BuildContext context) {
    return context.buttonTheme.buttonDisableColor;
  }

  @override
  Color focusColor(BuildContext context) {
    return context.buttonTheme.secondaryButtonFocused;
  }

  Color hoverColor(BuildContext context) {
    return context.buttonTheme.secondaryButtonHover;
  }

  @override
  Color textColor(BuildContext context) {
    return context.buttonTheme.secondaryButtonText;
  }
}
