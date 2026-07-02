import '../../../index/index.dart';

class AppText extends StatefulWidget {
  /// {@macro app_text_widget}
  const AppText({
    super.key,
    required this.text,
    required this.textStyle,
    this.textAlign ,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap,
    this.textScaler,
    this.locale,
    this.strutStyle,
    this.semanticsLabel,
    this.textWidthBasis,
    this.selectionColor,
  });

  /// The text to display.
  final String text;

  /// The type of text style based on predefined app themes.
  final TextStyle textStyle;

  /// The text alignment for the text widget.
  final TextAlign? textAlign;

  /// The text direction for the text widget.
  final TextDirection? textDirection;

  /// The maximum number of lines for the text.
  final int? maxLines;

  /// How overflowing text should be handled.
  final TextOverflow? overflow;

  /// Whether the text should break lines or not.
  final bool? softWrap;

  /// The scaling factor for the text.
  final TextScaler? textScaler;

  /// The locale for the text.
  final Locale? locale;

  /// Defines how the text is laid out vertically.
  final StrutStyle? strutStyle;

  /// Custom semantics label for accessibility.
  final String? semanticsLabel;

  /// The width basis for the text.
  final TextWidthBasis? textWidthBasis;

  /// The selection color for the text.
  final Color? selectionColor;

  @override
  State<AppText> createState() => _AppTextState();
}

class _AppTextState extends State<AppText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      textAlign: context.appTextTheme.textAlign ?? widget.textAlign,
      textDirection: widget.textDirection ?? context.appTextTheme.textDirection,
      maxLines: widget.maxLines ?? context.appTextTheme.maxLines,
      overflow: context.appTextTheme.overflow ?? widget.overflow,
      softWrap: context.appTextTheme.softWrap ?? widget.softWrap,
      textScaler: widget.textScaler,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textWidthBasis: widget.textWidthBasis,
      selectionColor: widget.selectionColor,
      semanticsLabel: widget.semanticsLabel,
      style: widget.textStyle,
    );
  }
}
