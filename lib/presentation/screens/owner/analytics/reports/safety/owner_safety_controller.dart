import '../../../../../../index/index_main.dart';

/// Incidents & Safety — the owner's risk view over `IncidentModel`: how many
/// incidents in the last 30 days, how severe, whether parents were told, and the
/// split by severity / type / branch. Scope-aware (each incident has branchId).
class OwnerSafetyController extends GetxController {
  late final OwnerReportsDataService _data;
  late final OwnerScopeService _scope;

  /// Rolling analysis window.
  static const int windowDays = 30;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<OwnerReportsDataService>();
    _scope = Get.find<OwnerScopeService>();
    _data.ensureLoaded();
  }

  RxBool get firstLoading => _data.isFirstLoading;
  Future<void> reload() => _data.refresh();

  OwnerScope get _s => _scope.scope.value;

  List<IncidentModel> get _recent => _data
      .incidentsFor(_s)
      .where((i) => OwnerReportsDataService.withinDays(i.occurredAt, windowDays))
      .toList();

  int get total => _recent.length;
  int get highCount => _recent.where((i) => i.severity == 'high').length;

  /// Share of incidents where the parent was notified.
  int get notifiedRate {
    if (_recent.isEmpty) return 0;
    return ((_recent.where((i) => i.parentNotified).length / _recent.length) *
            100)
        .round();
  }

  /// Distinct children involved (some incidents have no child attached).
  int get childrenAffected =>
      _recent.map((i) => i.childId).whereType<String>().toSet().length;

  /// Count per severity, worst first.
  List<LabelCount> get bySeverity => _rank(
        const ['high', 'medium', 'low'],
        (i) => i.severity,
        (k) => 'incident_severity_$k',
      );

  /// Count per incident type, busiest first.
  List<LabelCount> get byType {
    final counts = <String, int>{};
    for (final i in _recent) {
      final t = i.type.isEmpty ? 'other' : i.type;
      counts[t] = (counts[t] ?? 0) + 1;
    }
    final out = counts.entries
        .map((e) => LabelCount(
              labelKey: _typeKey(e.key),
              count: e.value,
              share: total == 0 ? 0 : e.value / total,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return out;
  }

  /// Per-branch incident count (network scope only), busiest first.
  List<LabelCount> get byBranch {
    if (!_s.isNetwork) return const [];
    final names = {
      for (final b in _scope.branches)
        if (b.key != null) b.key!: b.name,
    };
    final counts = <String, int>{};
    for (final i in _recent) {
      counts[i.branchId] = (counts[i.branchId] ?? 0) + 1;
    }
    final out = counts.entries
        .map((e) => LabelCount(
              label: names[e.key] ?? '—',
              count: e.value,
              share: total == 0 ? 0 : e.value / total,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return out;
  }

  List<LabelCount> _rank(
    List<String> order,
    String Function(IncidentModel) pick,
    String Function(String) keyOf,
  ) {
    return order.map((k) {
      final n = _recent.where((i) => pick(i) == k).length;
      return LabelCount(
        labelKey: keyOf(k),
        count: n,
        share: total == 0 ? 0 : n / total,
      );
    }).toList();
  }

  /// `IncidentModel.type` uses 'health' where localization keys use 'illness'.
  String _typeKey(String type) {
    final t = type == 'health' ? 'illness' : type;
    const known = ['injury', 'illness', 'behavior', 'other'];
    return 'incident_type_${known.contains(t) ? t : 'other'}';
  }
}

/// A labelled count row (severity / type / branch breakdowns). Exactly one of
/// [labelKey] (translated) or [label] (already resolved, e.g. a branch name).
class LabelCount {
  final String? labelKey;
  final String? label;
  final int count;
  final double share;
  const LabelCount({
    this.labelKey,
    this.label,
    required this.count,
    required this.share,
  });

  String get text => label ?? (labelKey ?? '').tr;
}
