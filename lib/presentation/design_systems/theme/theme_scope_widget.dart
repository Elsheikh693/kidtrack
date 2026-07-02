import '../../../index/index.dart';

const _kThemeMode = 'themeMode';

class ThemeScopeWidget extends StatefulWidget {
  const ThemeScopeWidget({
    super.key,
    required this.child,
    required this.preferences,
  });

  final Widget child;
  final SharedPreferences preferences;

  static Future<ThemeScopeWidget> initialize(Widget child) async {
    final preferences = await SharedPreferences.getInstance();
    return ThemeScopeWidget(preferences: preferences, child: child);
  }

  static ThemeScopeWidgetState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<ThemeScopeWidgetState>();
  }

  @override
  State<ThemeScopeWidget> createState() => ThemeScopeWidgetState();
}

class ThemeScopeWidgetState extends State<ThemeScopeWidget> {
  ThemeMode? _themeMode;

  Future<void> changeTo(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    try {
      await widget.preferences.setInt(
        _kThemeMode,
        ThemeMode.values.indexOf(themeMode),
      );
      setState(() => _themeMode = themeMode);
    } on Exception catch (_) {}
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final index = widget.preferences.getInt(_kThemeMode) ?? 1; // default: light
      _themeMode = ThemeMode.values[index];
    } on Exception catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    final appTheme = switch (_themeMode!) {
      ThemeMode.light => AppTheme.light(),
      ThemeMode.dark => AppTheme.light(),
      ThemeMode.system =>
        brightness == Brightness.dark ? AppTheme.light() : AppTheme.light(),
    };

    return ThemeScope(
      themeMode: _themeMode!,
      appTheme: appTheme,
      child: widget.child,
    );
  }
}
