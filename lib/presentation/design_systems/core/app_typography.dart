import '../../../index/index_main.dart';

/// Emoji-capable fallback fonts. IBMPlexSansArabic has no emoji glyphs, so
/// without these, any emoji renders as a tofu box (؟). These are system fonts
/// (built into iOS/Android) — no asset bundling needed.
///
/// Do NOT add a bundled `NotoColorEmoji.ttf` here: that font is a CBDT/CBLC
/// color-bitmap font that the Flutter text engine crashes on when loaded on
/// Apple platforms (killed the app on the first text-bearing screen). The two
/// system fonts below cover iOS and Android already.
const List<String> kEmojiFontFallback = <String>[
  'Apple Color Emoji',
  'Noto Color Emoji',
];

class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.xsBold,
    required this.mdRegular,
    required this.smRegular,
    required this.mdMedium,
    required this.xlBold,
    required this.xsRegular,
    required this.mdBold,
    required this.displaySmBold,
    required this.xsMedium,
    required this.smSemiBold,
    required this.lgBold,
    required this.smMedium,
    required this.xxlBold,
  });

  factory AppTypography.light() {
    return AppTypography(
      xsBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
      ),
      mdRegular: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      smRegular: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      mdMedium: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      xlBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        height: 30 / 20,
      ),
      xsRegular: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
      ),
      mdBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
      ),
      displaySmBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
      xsMedium: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        height: 18 / 12,
      ),
      smSemiBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
      ),
      lgBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 28 / 18,
      ),
      smMedium: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
      ),
      xxlBold: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontFamilyFallback: kEmojiFontFallback,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 40 / 30,
      ),
    );
  }

  /// Typography styles
  final TextStyle xsBold;
  final TextStyle mdRegular;
  final TextStyle smRegular;
  final TextStyle mdMedium;
  final TextStyle xlBold;
  final TextStyle xsRegular;
  final TextStyle mdBold;
  final TextStyle displaySmBold;
  final TextStyle xsMedium;
  final TextStyle smSemiBold;
  final TextStyle lgBold;
  final TextStyle smMedium;
  final TextStyle xxlBold;

  @override
  AppTypography copyWith({
    TextStyle? xsBold,
    TextStyle? mdRegular,
    TextStyle? smRegular,
    TextStyle? mdMedium,
    TextStyle? xlBold,
    TextStyle? xsRegular,
    TextStyle? mdBold,
    TextStyle? displaySmBold,
    TextStyle? xsMedium,
    TextStyle? smSemiBold,
    TextStyle? lgBold,
    TextStyle? smMedium,
    TextStyle? xxlBold,
  }) {
    return AppTypography(
      xsBold: xsBold ?? this.xsBold,
      mdRegular: mdRegular ?? this.mdRegular,
      smRegular: smRegular ?? this.smRegular,
      mdMedium: mdMedium ?? this.mdMedium,
      xlBold: xlBold ?? this.xlBold,
      xsRegular: xsRegular ?? this.xsRegular,
      mdBold: mdBold ?? this.mdBold,
      displaySmBold: displaySmBold ?? this.displaySmBold,
      xsMedium: xsMedium ?? this.xsMedium,
      smSemiBold: smSemiBold ?? this.smSemiBold,
      lgBold: lgBold ?? this.lgBold,
      smMedium: smMedium ?? this.smMedium,
      xxlBold: xxlBold ?? this.xxlBold,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;

    return AppTypography(
      xsBold: TextStyle.lerp(xsBold, other.xsBold, t)!,
      mdRegular: TextStyle.lerp(mdRegular, other.mdRegular, t)!,
      smRegular: TextStyle.lerp(smRegular, other.smRegular, t)!,
      mdMedium: TextStyle.lerp(mdMedium, other.mdMedium, t)!,
      xlBold: TextStyle.lerp(xlBold, other.xlBold, t)!,
      xsRegular: TextStyle.lerp(xsRegular, other.xsRegular, t)!,
      mdBold: TextStyle.lerp(mdBold, other.mdBold, t)!,
      displaySmBold: TextStyle.lerp(displaySmBold, other.displaySmBold, t)!,
      xsMedium: TextStyle.lerp(xsMedium, other.xsMedium, t)!,
      smSemiBold: TextStyle.lerp(smSemiBold, other.smSemiBold, t)!,
      lgBold: TextStyle.lerp(lgBold, other.lgBold, t)!,
      smMedium: TextStyle.lerp(smMedium, other.smMedium, t)!,
      xxlBold: TextStyle.lerp(xxlBold, other.xxlBold, t)!,
    );
  }
}
