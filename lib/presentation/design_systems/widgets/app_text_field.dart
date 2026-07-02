import '../../../index/index.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.formaters,
    this.hintText,
    this.enabled = true,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.focusNode,
    this.showShadow = true,
    this.prefixIcon,
    this.keyboardType,
    this.readOnly,
    this.ontap,
    this.textInputAction = TextInputAction.done, // "Done" action
    this.maxLines = 1,
    this.onValidationChanged, // Callback for validation state
  });

  final TextEditingController? controller;
  final String? labelText;
  final VoidCallback? ontap;
  final bool? readOnly;
  final String? hintText;
  final bool enabled;
  final bool showShadow;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? formaters;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? helperText;
  final String? errorText; // Determines if there’s an error
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final ValueChanged<bool>?
  onValidationChanged; // Callback to indicate validation success or failure

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {}); // Trigger UI update on focus state change
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose(); // Dispose only if locally created
    }
    super.dispose();
  }

  void _onFieldChanged(String value) {
    // Digits are already normalized to English by EnglishDigitsFormatter
    // (see inputFormatters below), so [value] is final here.
    final validationError = widget.validator?.call(value);
    final isValid = validationError == null;

    widget.onValidationChanged?.call(isValid);

    setState(() {
      _errorText = validationError;
    });

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.enabled
            ? isFocused && _errorText == null
                  ? context.inputTheme.backgroundFocused
                  : context.inputTheme.backgroundDefault
            : context.inputTheme.backgroundDisabled,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isFocused && _errorText == null
            ? widget.showShadow == false
                  ? []
                  : [
                      BoxShadow(
                        color: context.inputTheme.focusedTextColor.withValues(
                          alpha: 0.9,
                        ),
                        blurRadius: 2,
                        offset: const Offset(0, 1), // Shadow offset
                      ),
                    ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        onTap: widget.ontap,
        readOnly: widget.readOnly ?? false,
        focusNode: _focusNode,
        onChanged: _onFieldChanged,
        validator: widget.validator,
        inputFormatters: [
          const EnglishDigitsFormatter(),
          ...?widget.formaters,
        ],
        autovalidateMode: AutovalidateMode.onUnfocus,
        keyboardType: widget.keyboardType ?? TextInputType.name,
        textInputAction: widget.textInputAction,
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
        cursorColor: context.inputTheme.focusedTextColor,
        style: context.typography.mdRegular.copyWith(
          color: widget.enabled
              ? context.inputTheme.focusedTextColor
              : context.inputTheme.disabledTextColor,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          hintStyle: context.typography.mdRegular.copyWith(
            color: AppColors.textFieldPlaceholder,
          ),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.inputTheme.borderDefault.withValues(alpha: .45),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.inputTheme.borderFocused),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.inputTheme.borderError),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.inputTheme.borderError),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.inputTheme.borderDisabled),
            borderRadius: BorderRadius.circular(8),
          ),
          errorText: _errorText,
          helperText: widget.helperText,
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }
}
