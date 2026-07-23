import '../../../index/index_main.dart';

/// Local (SharedPreferences) persistence of which tutorial videos the current
/// user has finished watching. Shared by the list controller (to render step
/// progress) and the player (to mark a step done once its video completes).
class TutorialProgressStore {
  static const String _key = 'tutorial_watched_v1';

  static Set<String> watched() {
    final data = StorageService().getData(_key);
    final list = (data?['keys'] as List?)?.map((e) => e.toString()) ??
        const <String>[];
    return list.toSet();
  }

  static Future<void> markWatched(String key) async {
    if (key.isEmpty) return;
    final set = watched()..add(key);
    await StorageService().setData(_key, {'keys': set.toList()});
  }
}
