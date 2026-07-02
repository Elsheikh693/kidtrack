import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors — KidTrack Purple Palette ───────────────────────────────
  static Color primary10 = const Color(0xFFF0EBFF);
  static Color primary20 = const Color(0xFFDDD5FF);
  static Color primary40 = const Color(0xFFB8A8F8);
  static Color primary60 = const Color(0xFF8B72EF);
  static Color primaryFaint = const Color(0xFFF8F5FF);
  static Color primary80 = const Color(0xFF4527A0);
  static Color primary = const Color(0xFF5E35B1);
  static Color primaryLight = const Color(0xFFEDE7FF);
  static Color background = const Color(0xFFF5F3FF);

  // ── Background theme colors (dynamic) ────────────────────────────────────
  static Color bgColor      = const Color(0xFF0E0C0A);
  static Color surfaceColor = const Color(0xFF161412);
  static Color textOnBg     = const Color(0xFFF0EBE4);
  static Color mutedOnBg    = const Color(0xFF7A6F64);
  static Color borderOnBg   = const Color(0x12FFFFFF);

  static Color secondary10 = const Color(0xFFFCE4EC);
  static Color secondary20 = const Color(0xFFF8BBD0);
  static Color secondary40 = const Color(0xFFF48FB1);
  static Color secondary60 = const Color(0xFFF06292);
  static Color secondary80 = const Color(0xFFE91E8C);
  static Color secondary100 = const Color(0xFFAD1457);

  static Color backgroundPrimaryDefault = const Color(0xFF5E35B1);

  // ── Gradient getters (derived from brand colors) ──────────────────────────
  static LinearGradient get greenGradient => LinearGradient(
    colors: [primary20, white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9EAD7), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Apply brand palette from primary + secondary colors ───────────────────
  static void applyBrand(Color p, Color s, {Color? bg}) {
    final ph = HSLColor.fromColor(p);
    final sh = HSLColor.fromColor(s);

    primary = p;
    primary80 = ph
        .withLightness((ph.lightness - 0.08).clamp(0.0, 1.0))
        .toColor();
    primary60 = ph
        .withLightness((ph.lightness + 0.10).clamp(0.0, 1.0))
        .toColor();
    primary40 = ph
        .withLightness((ph.lightness + 0.22).clamp(0.0, 1.0))
        .toColor();
    primary20 = ph
        .withLightness((ph.lightness + 0.36).clamp(0.0, 1.0))
        .toColor();
    primary10 = ph
        .withLightness((ph.lightness + 0.46).clamp(0.0, 1.0))
        .toColor();
    primaryLight = ph
        .withLightness(0.96)
        .withSaturation((ph.saturation * 0.6).clamp(0.0, 1.0))
        .toColor();
    primaryFaint = ph
        .withLightness(0.97)
        .withSaturation((ph.saturation * 0.4).clamp(0.0, 1.0))
        .toColor();
    background = ph
        .withLightness(0.97)
        .withSaturation((ph.saturation * 0.5).clamp(0.0, 1.0))
        .toColor();
    backgroundPrimaryDefault = p;

    secondary100 = s;
    secondary80 = s;
    secondary60 = sh
        .withLightness((sh.lightness + 0.10).clamp(0.0, 1.0))
        .toColor();
    secondary40 = sh
        .withLightness((sh.lightness + 0.22).clamp(0.0, 1.0))
        .toColor();
    secondary20 = sh
        .withLightness((sh.lightness + 0.36).clamp(0.0, 1.0))
        .toColor();
    secondary10 = sh
        .withLightness((sh.lightness + 0.46).clamp(0.0, 1.0))
        .toColor();

    if (bg != null) {
      bgColor = bg;
      final bgh = HSLColor.fromColor(bg);
      final isDark = bgh.lightness < 0.5;
      surfaceColor = bgh
          .withLightness((bgh.lightness + (isDark ? 0.04 : -0.04)).clamp(0.0, 1.0))
          .toColor();
      textOnBg   = isDark ? const Color(0xFFF0EBE4) : const Color(0xFF1A1410);
      mutedOnBg  = isDark ? const Color(0xFF7A6F64) : const Color(0xFF6B6055);
      borderOnBg = isDark ? const Color(0x12FFFFFF) : const Color(0x15000000);
    }
  }

  // ── Neutral / Semantic Colors (const — never change) ─────────────────────

  static const Color stepperButtonUpcoming = Color(0xFFD2D6DB);

  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color successForeground = Color(0xFF4CAF50);

  static const Color errorBackground = Color(0xFFFEF3F3);
  static const Color errorForeground = Color(0xFFF14837);

  // ── Teacher Activity Colors ───────────────────────────────────────────────
  static const Color activityGreen = Color(0xFF16A34A);
  static const Color activityGreenDark = Color(0xFF14532D);
  static const Color activityGreenLight = Color(0xFFF0FDF4);
  static const Color activityGreenAccent = Color(0xFF4ADE80);
  static const Color activityRed = Color(0xFFDC2626);
  static const Color activityRedLight = Color(0xFFFEF2F2);
  static const Color activityAmber = Color(0xFFCA8A04);
  static const Color activityAmberLight = Color(0xFFFFFBEB);
  static const Color activityAmberBrand = Color(0xFFD97706);
  static const Color activityOrange = Color(0xFFEA580C);
  static const Color activityPurple = Color(0xFF7C3AED);
  static const Color activityPurpleLight = Color(0xFFF5F3FF);
  static const Color activityBlue = Color(0xFF0891B2);
  static const Color activitySlate = Color(0xFF1E293B);
  static const Color activityMuted = Color(0xFF94A3B8);

  static const Color dividerAndLines = Color(0xFFE0E0E2);

  static const Color backgroundPrimary = Color(0xFF161616);
  static const Color backgroundSecondary = Color(0xFF6C737F);

  static const Color blueLightBackground = Color(0xFFD0E8FF);
  static const Color blueForeground = Color(0xFF4A90E2);

  static const Color yellowBackground = Color(0xFFFFFBCF);
  static const Color yellowForeground = Color(0xFFF2BF12);
  static const Color ratingStar = Color(0xFFF5A623);
  static const Color teal = Color(0xFF00A2B8);

  static const Color grayLight = Color(0xFFE0E0E2);
  static const Color grayMedium = Color(0xFF8C8C8C);
  static const Color buttonDisabledTextColor = Color(0xFF9DA4AE);
  static const Color buttonDisabledColor = Color(0xFF9DA4AE);
  static const Color buttonpressedColor = Color(0xFF4D5761);

  static const Color shadowUpper = Color(0xFF8F8F8F);
  static const double shadowOpacity = 0.2;
  static const double shadowBlur = 20.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = -4.0;

  static const Color textDisplay = Color(0xFF1F2A37);
  static const Color textSecondaryParagraph = Color(0xFF6C737F);
  static const Color formFieldTextLabel = Color(0xFF161616);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDefault = Color(0xFF161616);
  static const Color textSteeper = Color(0xFF384250);

  static const Color textFieldPlaceholder = Color(0xFF6C737F);
  static const Color textFieldBorderDefault = Color(0xFF9DA4AE);
  static const Color textFieldBorderFocused = Color(0xFF0D121C);
  static const Color textFieldBackgroundFocused = Color(0xFFF3F4F6);
  static const Color borderNeutralPrimary = Color(0xFFD2D6DB);
  static const Color textFormTitle = Color(0xFF161616);

  static const Color backgroundBlackDefault = Color(0xFF0D121C);
  static const Color backgroundNeutralDefault = Color(0xFFF3F4F6);
  static const Color backgroundWarningLight = Color(0xFFFFFAEB);
  static const Color backgroundErrorLight = Color(0xFFFEF3F2);
  static const Color tagIconWarning = Color(0xFF93370D);
  static const Color tagTextError = Color(0xFF912018);
  static const Color backgroundNeutral100 = Color(0xFFF4F2FB);
  static const Color backgroundNeutral25 = Color(0xFFFCFCFD);
  static const Color fieldTextPlaceholder = Color(0xFF6C737F);
  static const Color backgroundNeutral800 = Color(0xFF1F2A37);
  static const Color backgroundBlack = Color(0xFF161616);
  static const Color textPrimaryParagraph = Color(0xFF384250);
  static const Color backgroundInfo50 = Color(0xFFEFF8FF);
  static const Color textInfo = Color(0xFF175CD3);

  static const Color closedBackground = Color(0xFFB54708);
  static const Color closedText = Color(0xFFB54708);
  static const Color pending = Color(0xFF1570EF);
  static const Color notStart = Color(0xFFFFB300);

  static const Color colorGrey50 = Color(0xFFEBEBEB);
  static const Color colorGrey70 = Color(0xFF989898);
  static const Color colorGreyLight = Color(0xFFE5E5E5);
}

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }
}
