import '../../../../../../index/index_main.dart';

/// Daily Care — the nursery-floor view over `DailyCareLogModel` for this month:
/// how many logs, children covered, average nap length and diaper changes, plus
/// the meal-outcome and mood distributions. Network-level.
class OwnerCareController extends GetxController {
  late final DailyCareLogParentService _svc;

  final RxBool isLoading = false.obs;
  final _logs = <DailyCareLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _svc = Get.find<DailyCareLogParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _fetch<DailyCareLogModel>(_svc.getAll);
      _logs.assignAll(list.cast<DailyCareLogModel>());
    } finally {
      isLoading.value = false;
    }
  }

  DateTime get _month {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  List<DailyCareLogModel> get _monthLogs => _logs.where(_thisMonth).toList();

  int get logCount => _monthLogs.length;
  int get childrenCovered =>
      _monthLogs.map((l) => l.childId).toSet().length;

  /// Mean nap length (minutes) over logs that recorded both ends.
  int get avgNapMinutes {
    final naps = _monthLogs
        .where((l) => l.sleepStart != null && l.sleepEnd != null)
        .map((l) => (l.sleepEnd! - l.sleepStart!) / 60000)
        .where((m) => m > 0)
        .toList();
    if (naps.isEmpty) return 0;
    return (naps.reduce((a, b) => a + b) / naps.length).round();
  }

  double get avgDiapers {
    final logs = _monthLogs;
    if (logs.isEmpty) return 0;
    return logs.fold<int>(0, (s, l) => s + l.diaperChanges) / logs.length;
  }

  bool get isEmpty => _monthLogs.isEmpty;

  /// Meal outcomes across all recorded meal slots (breakfast+lunch+snack).
  List<CareSlice> get mealOutcomes {
    final counts = <String, int>{'ate_all': 0, 'ate_some': 0, 'did_not_eat': 0};
    for (final l in _monthLogs) {
      for (final s in [l.breakfastStatus, l.lunchStatus, l.snackStatus]) {
        if (s != null && counts.containsKey(s)) counts[s] = counts[s]! + 1;
      }
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    return counts.entries
        .map((e) => CareSlice(
              labelKey: 'owner_report_ca_meal_${e.key}',
              count: e.value,
              share: total == 0 ? 0 : e.value / total,
            ))
        .toList();
  }

  /// Mood distribution.
  List<CareSlice> get moods {
    const order = ['happy', 'calm', 'cranky', 'sick'];
    final counts = <String, int>{for (final k in order) k: 0};
    for (final l in _monthLogs) {
      final m = l.mood;
      if (m != null && counts.containsKey(m)) counts[m] = counts[m]! + 1;
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    return order
        .map((k) => CareSlice(
              labelKey: 'owner_report_ca_mood_$k',
              count: counts[k]!,
              share: total == 0 ? 0 : counts[k]! / total,
            ))
        .toList();
  }

  bool _thisMonth(DailyCareLogModel l) {
    final parts = l.date.split('-');
    if (parts.length < 2) return false;
    return int.tryParse(parts[0]) == _month.year &&
        int.tryParse(parts[1]) == _month.month;
  }

  Future<List<T>> _fetch<T>(
      Future<void> Function({required Function(List<T?>) callBack}) getAll) {
    final c = Completer<List<T>>();
    getAll(callBack: (list) {
      if (!c.isCompleted) c.complete(list.whereType<T>().toList());
    });
    return c.future;
  }
}

/// One care breakdown bar (meal outcome / mood).
class CareSlice {
  final String labelKey;
  final int count;
  final double share;
  const CareSlice({
    required this.labelKey,
    required this.count,
    required this.share,
  });
}
