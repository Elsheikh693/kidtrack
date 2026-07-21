import '../../index/index_main.dart';

/// Central registry mapping a stable string key — stored in the database as
/// [EvalLevelTemplateModel.icon] — to a Material [IconData]. Mirrors
/// [ChildStateIcons]. Unknown/legacy values fall back to [fallback].
class EvalLevelIcons {
  EvalLevelIcons._();

  static const IconData fallback = Icons.star_rounded;

  /// Default key selected for a brand-new eval level.
  static const String defaultKey = 'excellent';

  static const List<({String key, IconData icon})> presets = [
    (key: 'excellent', icon: Icons.sentiment_very_satisfied_rounded),
    (key: 'good', icon: Icons.sentiment_satisfied_rounded),
    (key: 'follow', icon: Icons.sentiment_neutral_rounded),
    (key: 'support', icon: Icons.sentiment_dissatisfied_rounded),
    (key: 'weak', icon: Icons.sentiment_very_dissatisfied_rounded),
    (key: 'star', icon: Icons.star_rounded),
    (key: 'medal', icon: Icons.military_tech_rounded),
    (key: 'thumb_up', icon: Icons.thumb_up_rounded),
    (key: 'thumb_down', icon: Icons.thumb_down_rounded),
    (key: 'heart', icon: Icons.favorite_rounded),
    (key: 'flag', icon: Icons.flag_rounded),
    (key: 'bolt', icon: Icons.bolt_rounded),
    (key: 'check', icon: Icons.check_circle_rounded),
    (key: 'warning', icon: Icons.warning_rounded),
    (key: 'eye', icon: Icons.remove_red_eye_rounded),
    (key: 'rocket', icon: Icons.rocket_launch_rounded),
  ];

  static IconData iconFor(String key) {
    for (final p in presets) {
      if (p.key == key) return p.icon;
    }
    return fallback;
  }
}

/// Preset colors offered in the eval-level editor.
class EvalLevelPalette {
  EvalLevelPalette._();

  static const int defaultColor = 0xFF16A34A;

  static const List<int> presets = [
    0xFF16A34A, // green
    0xFF059669, // emerald
    0xFF0891B2, // cyan
    0xFF2563EB, // blue
    0xFF7C3AED, // violet
    0xFFD97706, // amber
    0xFFF59E0B, // orange
    0xFFDC2626, // red
    0xFFEC4899, // pink
    0xFF64748B, // slate
  ];
}
