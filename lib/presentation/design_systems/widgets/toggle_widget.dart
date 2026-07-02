import '../../../index/index.dart';

class ToggleButtonWidget extends StatelessWidget {
  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.children,
    this.onPressed,
    this.color,
    this.selectedColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.borderColor,
    this.selectedBorderColor,
    this.disabledColor,
    this.borderRadius,
    this.constraints,
    this.mouseCursor,
    this.focusNodes,
    this.autofocus = false,
  });

  final List<bool> isSelected;
  final List<Widget> children;
  final void Function(int index)? onPressed;
  final Color? color;
  final Color? selectedColor;
  final Color? fillColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? disabledColor;
  final BorderRadius? borderRadius;
  final BoxConstraints? constraints;
  final MouseCursor? mouseCursor;
  final List<FocusNode>? focusNodes;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // Access the custom toggle theme from the context
    final toggleTheme = Theme.of(context).extension<AppToggleThemeExtension>();

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: onPressed,
      color: color ?? toggleTheme?.inactiveColor,
      selectedColor: selectedColor ?? toggleTheme?.activeColor,
      fillColor: fillColor ?? toggleTheme?.trackColor,
      focusColor: focusColor ?? toggleTheme?.splashColor,
      hoverColor: hoverColor ?? toggleTheme?.overlayColor,
      highlightColor: highlightColor ?? toggleTheme?.splashColor,
      borderColor: borderColor ?? toggleTheme?.inactiveColor,
      selectedBorderColor: selectedBorderColor ?? toggleTheme?.activeColor,
      disabledColor: disabledColor ?? Colors.grey,
      borderRadius:
          borderRadius is BorderRadius ? borderRadius : BorderRadius.zero,
      constraints: constraints ??
          BoxConstraints(
            minWidth: toggleTheme?.size ?? 40.0,
            minHeight: toggleTheme?.size ?? 40.0,
          ),
      mouseCursor: mouseCursor ?? SystemMouseCursors.click,
      focusNodes: focusNodes,
      children: children,
      // autofocus: autofocus,
    );
  }
}
