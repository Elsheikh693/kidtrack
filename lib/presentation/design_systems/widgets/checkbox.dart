import '../../../index/index.dart';

class AppCheckbox extends StatelessWidget {
  /// {@macro app_checkbox}
  const AppCheckbox({
    super.key,
    this.value = false,
    this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.materialTapTargetSize,
    this.shape,
    this.side,
    this.visualDensity,
    this.mouseCursor,
    this.autofocus = false,
    this.focusNode,
  });

  /// The value for the checkbox.
  final bool value;

  /// Called when the checkbox value changes.
  final ValueChanged<bool?>? onChanged;

  /// Whether the checkbox supports a tristate value.
  final bool tristate;

  /// The color of the checkbox when it's checked.
  final Color? activeColor;

  /// The color of the check icon.
  final Color? checkColor;

  /// The color of the checkbox when it's focused.
  final Color? focusColor;

  /// The color of the checkbox when it's hovered.
  final Color? hoverColor;

  /// The tap target size for the checkbox.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// The shape of the checkbox.
  final OutlinedBorder? shape;

  /// The side (border) of the checkbox.
  final BorderSide? side;

  /// The density of the visual representation of the checkbox.
  final VisualDensity? visualDensity;

  /// The cursor for mouse interaction.
  final MouseCursor? mouseCursor;

  /// Whether the checkbox should automatically focus.
  final bool autofocus;

  /// The focus node associated with the checkbox.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
      activeColor: activeColor ?? context.appCheckBoxTheme.activeColor,
      checkColor: checkColor ?? context.appCheckBoxTheme.checkColor,
      focusColor: focusColor ?? context.appCheckBoxTheme.focusColor,
      hoverColor: hoverColor ?? context.appCheckBoxTheme.hoverColor,
      materialTapTargetSize: materialTapTargetSize ??
          context.appCheckBoxTheme.materialTapTargetSize,
      shape: shape ?? context.appCheckBoxTheme.shape,
      side: side ?? context.appCheckBoxTheme.side,
      visualDensity: visualDensity ?? context.appCheckBoxTheme.visualDensity,
      mouseCursor: mouseCursor ?? context.appCheckBoxTheme.mouseCursor,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}
