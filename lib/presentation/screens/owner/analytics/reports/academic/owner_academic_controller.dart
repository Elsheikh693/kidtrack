import '../../../../../../index/index_main.dart';

/// Academic Performance — turns the written-exam results (`ExamResultModel`)
/// into a school-wide picture: average grade, pass/excellence rates, the grade
/// mix, and which subjects are strongest/weakest. Scope-aware (network or a
/// single branch) since every result carries its own `branchId`.
class OwnerAcademicController extends GetxController {
  late final OwnerReportsDataService _data;
  late final OwnerScopeService _scope;

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

  List<ExamResultModel> get _results => _data.examResultsFor(_s);

  List<ExamGrade> get _grades =>
      _results.map((r) => ExamGrade.fromKey(r.grade)).whereType<ExamGrade>().toList();

  int get resultCount => _grades.length;
  int get examCount => _results.map((r) => r.examId).toSet().length;

  /// Mean grade on the 1–5 scale (5 = excellent), one decimal.
  double get avgScore {
    final g = _grades;
    if (g.isEmpty) return 0;
    return g.fold<int>(0, (s, e) => s + e.score) / g.length;
  }

  /// Share of results at "good" or better (score ≥ 3).
  int get successRate {
    final g = _grades;
    if (g.isEmpty) return 0;
    return ((g.where((e) => e.score >= 3).length / g.length) * 100).round();
  }

  /// Share of results graded "excellent" (score == 5).
  int get excellenceRate {
    final g = _grades;
    if (g.isEmpty) return 0;
    return ((g.where((e) => e.score == 5).length / g.length) * 100).round();
  }

  /// Count per grade, in scale order (excellent → needs-improvement).
  List<GradeSlice> get gradeDistribution {
    final total = resultCount;
    return ExamGrade.values.map((grade) {
      final n = _grades.where((e) => e == grade).length;
      return GradeSlice(
        grade: grade,
        count: n,
        share: total == 0 ? 0 : n / total,
      );
    }).toList();
  }

  /// Per-subject average score, ranked strongest-first (min 1 result).
  List<SubjectScore> get subjectScores {
    final byName = <String, List<int>>{};
    for (final r in _results) {
      final g = ExamGrade.fromKey(r.grade);
      if (g == null) continue;
      final name = r.subjectName.trim().isEmpty ? '—' : r.subjectName.trim();
      byName.putIfAbsent(name, () => []).add(g.score);
    }
    final out = byName.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return SubjectScore(subject: e.key, avg: avg, count: e.value.length);
    }).toList()
      ..sort((a, b) => b.avg.compareTo(a.avg));
    return out;
  }
}

/// One bar in the grade-distribution breakdown.
class GradeSlice {
  final ExamGrade grade;
  final int count;
  final double share;
  const GradeSlice({
    required this.grade,
    required this.count,
    required this.share,
  });
}

/// One subject's average exam score.
class SubjectScore {
  final String subject;
  final double avg;
  final int count;
  const SubjectScore({
    required this.subject,
    required this.avg,
    required this.count,
  });
}
