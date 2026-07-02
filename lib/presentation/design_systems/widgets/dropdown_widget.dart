import '../../../index/index.dart';

class AppDropdown<T> extends StatelessWidget {
  /// {@macro app_dropdown}
  const AppDropdown({
    super.key,
    required this.items,
    this.onChanged,
    this.value,
    this.hint,
    this.labelText,
    this.errorText,
    this.helperText,
    this.isExpanded = false,
    this.enabled = true,
    this.icon,
  });

  /// The list of items for the dropdown.
  final List<DropdownMenuItem<T>> items;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// The current selected value.
  final T? value;

  /// Hint text displayed inside the dropdown.
  final Widget? hint;

  /// Label text for the dropdown.
  final String? labelText;

  /// Error text displayed below the dropdown.
  final String? errorText;

  /// Helper text displayed below the dropdown.
  final String? helperText;

  /// Whether the dropdown is expanded to fill the available space.
  final bool isExpanded;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Icon displayed at the dropdown's trailing edge.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final dropdownTheme = context.appDropdownTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              labelText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dropdownTheme.textColor,
                  ),
            ),
          ),
        DropdownButtonFormField<T>(
          items: items,
          initialValue: value,
          hint: hint,
          isExpanded: isExpanded,
          onChanged: enabled ? onChanged : null,
          icon: icon ??
              Icon(Icons.arrow_drop_down, color: dropdownTheme.iconColor),
          iconSize: dropdownTheme.iconSize,
          style: TextStyle(color: dropdownTheme.textColor),
          dropdownColor: dropdownTheme.menuBackgroundColor,
          menuMaxHeight: dropdownTheme.menuMaxHeight,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? dropdownTheme.backgroundColor
                : dropdownTheme.disabledBackgroundColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: dropdownTheme.borderRadius as BorderRadius,
              borderSide: BorderSide(
                color: dropdownTheme.borderColor,
                width: dropdownTheme.borderWidth,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: dropdownTheme.borderRadius as BorderRadius,
              borderSide: BorderSide(
                color: dropdownTheme.borderColor,
                width: dropdownTheme.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: dropdownTheme.borderRadius as BorderRadius,
              borderSide: BorderSide(
                color: dropdownTheme.focusedBorderColor,
                width: dropdownTheme.borderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: dropdownTheme.borderRadius as BorderRadius,
              borderSide: BorderSide(
                color: dropdownTheme.borderColor,
                width: dropdownTheme.borderWidth,
              ),
            ),
            helperText: helperText,
            helperStyle: TextStyle(color: dropdownTheme.textColor),
            errorText: errorText,
            errorStyle: TextStyle(color: dropdownTheme.unselectedItemColor),
          ),
        ),
      ],
    );
  }
}
