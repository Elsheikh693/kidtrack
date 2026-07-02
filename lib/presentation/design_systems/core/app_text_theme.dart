import 'dart:ui';
import '../../../index/index.dart';

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.text,
    required this.textAlign,
    required this.textDirection,
    required this.maxLines,
    required this.overflow,
    required this.softWrap,
    required this.textScaleFactor,
    required this.strutStyle,
    required this.textWidthBasis,
    required this.locale,
    required this.style,
    required this.selectionColor,
    required this.semanticsLabel,
  });

  /// The actual text content.
  final String text;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// The maximum number of lines the text can occupy.
  final int? maxLines;

  /// How to handle text overflow (e.g., ellipsis, fade).
  final TextOverflow? overflow;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// The scaling factor to apply to the text.
  final double? textScaleFactor;

  /// Defines the vertical alignment and line height.
  final StrutStyle? strutStyle;

  /// Determines how the width of the text is calculated.
  final TextWidthBasis? textWidthBasis;

  /// The locale used for rendering the text.
  final Locale? locale;

  /// The text style (e.g., font size, color, weight).
  final TextStyle? style;

  /// The background selection color.
  final Color? selectionColor;

  /// A semantic label used for accessibility.
  final String? semanticsLabel;

  /// Factory method to define a default theme.
  factory AppTextTheme.light() {
    return const AppTextTheme(
      text: "",
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.clip,
      softWrap: true,
      textScaleFactor: 1.0,
      strutStyle: null,
      textWidthBasis: TextWidthBasis.parent,
      locale: null,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
      selectionColor: null,
      semanticsLabel: null,
    );
  }

  @override
  AppTextTheme copyWith({
    String? text,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    double? textScaleFactor,
    StrutStyle? strutStyle,
    TextWidthBasis? textWidthBasis,
    Locale? locale,
    TextStyle? style,
    Color? selectionColor,
    String? semanticsLabel,
  }) {
    return AppTextTheme(
      text: text ?? this.text,
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
      softWrap: softWrap ?? this.softWrap,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      strutStyle: strutStyle ?? this.strutStyle,
      textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      locale: locale ?? this.locale,
      style: style ?? this.style,
      selectionColor: selectionColor ?? this.selectionColor,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    );
  }

  @override
  ThemeExtension<AppTextTheme> lerp(
      ThemeExtension<AppTextTheme>? other, double t) {
    if (other is! AppTextTheme) return this;

    return AppTextTheme(
      text: text,
      textAlign: textAlign ?? other.textAlign,
      textDirection: textDirection ?? other.textDirection,
      maxLines: maxLines ?? other.maxLines,
      overflow: overflow ?? other.overflow,
      softWrap: softWrap ?? other.softWrap,
      textScaleFactor: lerpDouble(textScaleFactor, other.textScaleFactor, t),
      strutStyle: strutStyle ?? other.strutStyle,
      textWidthBasis: textWidthBasis ?? other.textWidthBasis,
      locale: locale ?? other.locale,
      style: TextStyle.lerp(style, other.style, t),
      selectionColor:
          Color.lerp(selectionColor, other.selectionColor, t) ?? Colors.black,
      semanticsLabel: semanticsLabel,
    );
  }
}
