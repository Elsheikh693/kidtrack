import '../../../../index/index_main.dart';

enum EvalFilter { all, unevaluated, excellent, needsFollow, needsAttention }

/// Scopes the live activity panels (evaluation list, progress, filters) to the
/// activity's PARTICIPANTS. For a whole-class session that's the present class;
/// for a subset "activity" (teacher picked specific children) it's the fixed
/// picked set stored on [ClassroomActivityModel.childIds]. Kept out of the
/// controller to hold it under the size limit and localise the scoping rule.
mixin ActivityParticipantsMixin on GetxController {
  // Provided by the host controller.
  RxList<ChildModel> get children;
  List<ChildModel> get presentChildren;
  Rxn<ClassroomActivityModel> get activeActivity;
  RxString get searchQuery;
  Rx<EvalFilter> get evalFilter;

  /// The children the live activity acts on. A subset activity is pinned to its
  /// picked participants; a class session falls back to the present class (so
  /// latecomers still appear).
  List<ChildModel> get participantChildren {
    final a = activeActivity.value;
    if (a != null && a.isActivityMode && a.childIds.isNotEmpty) {
      final set = a.childIds.toSet();
      return children.where((c) => set.contains(c.key)).toList();
    }
    return presentChildren;
  }

  List<ChildModel> get filteredChildren {
    var list = participantChildren;
    final q = searchQuery.value.trim();
    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.fullName.contains(q) ||
              c.firstName.contains(q) ||
              c.lastName.contains(q))
          .toList();
    }
    final filter = evalFilter.value;
    final activity = activeActivity.value;
    if (filter != EvalFilter.all && activity != null) {
      list = list.where((c) {
        final eval = activity.evalFor(c.key ?? '');
        return switch (filter) {
          EvalFilter.unevaluated => eval == null,
          EvalFilter.excellent => eval == EvalLevel.excellent,
          EvalFilter.needsFollow => eval == EvalLevel.needsFollow,
          EvalFilter.needsAttention => eval == EvalLevel.needsAttention,
          EvalFilter.all => true,
        };
      }).toList();
    }
    return list;
  }

  int get evaluatedCount => activeActivity.value?.evaluations.length ?? 0;

  int get unevaluatedCount {
    final total = participantChildren.length;
    return (total - evaluatedCount).clamp(0, total);
  }

  double get evalProgress {
    final total = participantChildren.length;
    return total == 0 ? 0.0 : (evaluatedCount / total).clamp(0.0, 1.0);
  }
}
