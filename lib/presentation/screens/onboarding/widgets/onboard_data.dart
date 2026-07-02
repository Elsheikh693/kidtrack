import '../../../../index/index_main.dart';

/// A single orbiting icon chip rendered around the central hero.
class OnboardSatellite {
  final IconData icon;
  final Color color;

  const OnboardSatellite(this.icon, this.color);
}

/// Content + theming for one onboarding page. The scene is fully drawn in
/// Flutter (no Lottie) so it can be themed per page and stay crisp.
class OnboardData {
  final IconData heroIcon;
  final List<OnboardSatellite> satellites;
  final String chip;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color accentColor2;
  final Color accentLight;

  const OnboardData({
    required this.heroIcon,
    required this.satellites,
    required this.chip,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.accentColor2,
    required this.accentLight,
  });
}
