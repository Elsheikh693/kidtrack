import '../../index/index_main.dart';

/// Central registry mapping a stable string key — stored in the database as
/// [ChildStateTemplateModel.icon] — to a Material [IconData].
///
/// State templates used to store raw emoji, which render as tofu ("?") on
/// devices without a color-emoji font. We now store one of the [presets] keys
/// instead. Any unknown or legacy (emoji) value falls back to [fallback].
class ChildStateIcons {
  ChildStateIcons._();

  static const IconData fallback = Icons.child_care_rounded;

  /// Default key selected for a brand-new state template.
  static const String defaultKey = 'sleep';

  static const List<({String key, IconData icon})> presets = [
    (key: 'sleep', icon: Icons.bedtime_rounded),
    (key: 'food', icon: Icons.restaurant_rounded),
    (key: 'diaper', icon: Icons.baby_changing_station_rounded),
    (key: 'bottle', icon: Icons.local_drink_rounded),
    (key: 'medicine', icon: Icons.medical_services_rounded),
    (key: 'bath', icon: Icons.shower_rounded),
    (key: 'study', icon: Icons.menu_book_rounded),
    (key: 'art', icon: Icons.palette_rounded),
    (key: 'play', icon: Icons.sports_soccer_rounded),
    (key: 'toy', icon: Icons.toys_rounded),
    (key: 'toilet', icon: Icons.wc_rounded),
    (key: 'snack', icon: Icons.bakery_dining_rounded),
    (key: 'drink', icon: Icons.local_cafe_rounded),
    (key: 'music', icon: Icons.music_note_rounded),
    (key: 'swim', icon: Icons.pool_rounded),
    (key: 'brush', icon: Icons.clean_hands_rounded),
    (key: 'happy', icon: Icons.sentiment_satisfied_rounded),
    (key: 'star', icon: Icons.star_rounded),
  ];

  /// Resolves the [IconData] for a stored [key]; returns [fallback] when the
  /// key is unknown (including legacy emoji values).
  static IconData iconFor(String key) {
    for (final p in presets) {
      if (p.key == key) return p.icon;
    }
    return fallback;
  }
}
