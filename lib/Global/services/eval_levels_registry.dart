import '../../index/index_main.dart';

/// App-wide cache of the nursery's active evaluation levels, so any widget can
/// resolve an eval key → (title, icon, color, score) synchronously without
/// re-reading Firebase. Registered permanent in bindings; refreshed at login
/// and whenever the eval-levels settings screen saves.
///
/// Unknown keys fall back to the built-in legacy defaults
/// (excellent/needs_follow/needs_attention) so old evaluations always resolve.
class EvalLevelsRegistry {
  EvalLevelsRegistry();

  static EvalLevelsRegistry get instance => Get.find<EvalLevelsRegistry>();

  final EvalLevelService _service = EvalLevelService();
  final SessionService _session = SessionService();

  /// Active levels ordered highest-score first. Reactive: widgets inside an Obx
  /// that read this rebuild when the levels change.
  final RxList<EvalLevelTemplateModel> levels = <EvalLevelTemplateModel>[].obs;

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded && levels.isNotEmpty) return;
    await load();
  }

  Future<void> load() async {
    final list = await _service.loadActiveTemplates(_session.nurseryId ?? '');
    levels.value = list.isEmpty ? _fallbackList() : list;
    _loaded = true;
  }

  List<EvalLevelTemplateModel> _fallbackList() =>
      EvalLevelDefaults.seed.map(_fromSeedKey).toList();

  EvalLevelTemplateModel _fromSeedKey(
      ({String key, String titleKey, String icon, int color, double score}) d) {
    return EvalLevelTemplateModel(
      key: d.key,
      nurseryId: '',
      title: d.titleKey.tr,
      icon: d.icon,
      color: d.color,
      score: d.score,
      createdAt: 0,
    );
  }

  /// The level for [key], falling back to a legacy default when the stored key
  /// isn't among the loaded active levels (e.g. a deleted/renamed level still
  /// referenced by an old activity).
  EvalLevelTemplateModel? byKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final l in levels) {
      if (l.key == key) return l;
    }
    for (final d in EvalLevelDefaults.seed) {
      if (d.key == key) return _fromSeedKey(d);
    }
    return null;
  }

  double scoreFor(String? key) => byKey(key)?.score ?? 0.0;
  String titleFor(String? key) => byKey(key)?.title ?? '';
  Color colorFor(String? key) =>
      Color(byKey(key)?.color ?? 0xFF64748B);
  IconData iconFor(String? key) =>
      EvalLevelIcons.iconFor(byKey(key)?.icon ?? '');

  /// The default (highest-score) level's key, used to preselect a value.
  String? get topKey => levels.isNotEmpty ? levels.first.key : 'excellent';
}
