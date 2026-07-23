import '../../../../../../index/index_main.dart';

/// Parent Satisfaction — the owner's read on how families rate the nursery, from
/// the one-per-family `NurseryFeedbackModel` (1–5 stars + tags). Network-level:
/// feedback carries no branch dimension, so the scope switcher is hidden.
class OwnerSatisfactionController extends GetxController {
  late final OwnerReportsDataService _data;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<OwnerReportsDataService>();
    _data.ensureLoaded();
  }

  RxBool get firstLoading => _data.isFirstLoading;
  Future<void> reload() => _data.refresh();

  List<NurseryFeedbackModel> get _all =>
      _data.feedback.where((f) => f.rating >= 1 && f.rating <= 5).toList();

  int get responseCount => _all.length;

  /// Mean rating, one decimal.
  double get avgRating {
    if (_all.isEmpty) return 0;
    return _all.fold<int>(0, (s, f) => s + f.rating) / _all.length;
  }

  /// Share of happy families (4–5 stars).
  int get satisfactionRate {
    if (_all.isEmpty) return 0;
    return ((_all.where((f) => f.rating >= 4).length / _all.length) * 100)
        .round();
  }

  /// Share of unhappy families (1–2 stars) — the follow-up list.
  int get detractorRate {
    if (_all.isEmpty) return 0;
    return ((_all.where((f) => f.rating <= 2).length / _all.length) * 100)
        .round();
  }

  /// Count per star level, 5★ first.
  List<RatingSlice> get ratingDistribution {
    final total = responseCount;
    return [5, 4, 3, 2, 1].map((stars) {
      final n = _all.where((f) => f.rating == stars).length;
      return RatingSlice(
        stars: stars,
        count: n,
        share: total == 0 ? 0 : n / total,
      );
    }).toList();
  }

  /// Most-cited feedback tags, busiest first (top 8).
  List<TagCount> get topTags {
    final counts = <String, int>{};
    for (final f in _all) {
      for (final t in f.tags) {
        final tag = t.trim();
        if (tag.isEmpty) continue;
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final out = counts.entries
        .map((e) => TagCount(tag: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return out.take(8).toList();
  }
}

/// One bar in the star-rating breakdown.
class RatingSlice {
  final int stars;
  final int count;
  final double share;
  const RatingSlice({
    required this.stars,
    required this.count,
    required this.share,
  });
}

/// One feedback tag's frequency.
class TagCount {
  final String tag;
  final int count;
  const TagCount({required this.tag, required this.count});
}
