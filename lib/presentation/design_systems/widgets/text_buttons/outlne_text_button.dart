import '../../../../index/index.dart';

class OutlineTextButton extends AppTextButton {
  /// {@macro outline_text_button}
  const OutlineTextButton({
    super.key,
    required super.label,
    super.onTap,
    super.leading,
    super.trailing,
    super.appButtonSize,
  });

  @override
  Color backgroundColor(BuildContext context) {
    return context.buttonTheme.outlineButtonDefault;
  }

  @override
  Color disabledColor(BuildContext context) {
    return context.buttonTheme.buttonDisableColor;
  }

  @override
  Color focusColor(BuildContext context) {
    return context.buttonTheme.outlineButtonFocused;
  }

  Color hoverColor(BuildContext context) {
    return context.buttonTheme.outlineButtonHover;
  }

  @override
  Color textColor(BuildContext context) {
    return context.buttonTheme.primaryTextButton;
  }

  @override
  BorderSide defaultBorder(BuildContext context) {
    return BorderSide(
      color: context.buttonTheme.outlineButtonDefault,
    );
  }

  @override
  BorderSide focusedBorder(BuildContext context) {
    return BorderSide(
      color: context.buttonTheme.outlineButtonFocused,
    );
  }

  @override
  BorderSide hoverBorder(BuildContext context) {
    return BorderSide(
      color: context.buttonTheme.outlineButtonHover,
    );
  }

  @override
  BorderSide disabledBorder(BuildContext context) {
    return BorderSide(
      color: context.buttonTheme.buttonDisableColor,
    );
  }
}
