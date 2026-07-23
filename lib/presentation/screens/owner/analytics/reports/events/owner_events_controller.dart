import '../../../../../../index/index_main.dart';

/// Events — the owner's read on nursery events (trips, parties, graduations…):
/// how many are running, how many upcoming, total attendance and the estimated
/// fee revenue, plus the split by category. Network-level. Courses are NOT
/// included (their enrolments don't post financial transactions).
class OwnerEventsController extends GetxController {
  final EventService _events = EventService();

  final RxBool isLoading = false.obs;
  final _all = <NurseryEventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _events.watchAllEvents().first;
      _all.assignAll(list.where((e) => e.isActive));
    } finally {
      isLoading.value = false;
    }
  }

  int get total => _all.length;
  int get upcoming => _all.where((e) => e.isUpcoming).length;
  int get attendees => _all.fold<int>(0, (s, e) => s + e.attendeesCount);

  /// Estimated fee revenue = Σ price × attendees over paid events.
  double get estRevenue => _all.fold<double>(
      0, (s, e) => s + ((e.price ?? 0) * e.attendeesCount));

  bool get isEmpty => _all.isEmpty;

  /// Event count per category, busiest first.
  List<EventCategoryCount> get byCategory {
    final counts = <EventCategory, int>{};
    for (final e in _all) {
      counts[e.category] = (counts[e.category] ?? 0) + 1;
    }
    final max = counts.values.fold<int>(0, (m, c) => c > m ? c : m);
    final out = counts.entries
        .map((e) => EventCategoryCount(
              category: e.key,
              count: e.value,
              share: max == 0 ? 0 : e.value / max,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return out;
  }
}

/// One event-category bar.
class EventCategoryCount {
  final EventCategory category;
  final int count;
  final double share;
  const EventCategoryCount({
    required this.category,
    required this.count,
    required this.share,
  });
}
