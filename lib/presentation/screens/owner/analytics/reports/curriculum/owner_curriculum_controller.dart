import '../../../../../../index/index_main.dart';

/// Curriculum Coverage — how far each classroom has got through the syllabus.
/// Cross-references the active `AcademicTopicModel` catalogue against the
/// `TopicProgressModel` completions teachers tick off. Network-level.
class OwnerCurriculumController extends GetxController {
  late final AcademicTopicParentService _topicSvc;
  late final TopicProgressParentService _progressSvc;
  late final ClassroomParentService _classroomSvc;

  final RxBool isLoading = false.obs;

  final _topics = <AcademicTopicModel>[].obs;
  final _progress = <TopicProgressModel>[].obs;
  final _classroomNames = <String, String>{};

  @override
  void onInit() {
    super.onInit();
    _topicSvc = Get.find<AcademicTopicParentService>();
    _progressSvc = Get.find<TopicProgressParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final r = await Future.wait([
        _fetch<AcademicTopicModel>(_topicSvc.getAll),
        _fetch<TopicProgressModel>(_progressSvc.getAll),
        _fetch<ClassroomModel>(_classroomSvc.getAll),
      ]);
      _topics.assignAll(r[0].cast<AcademicTopicModel>());
      _progress.assignAll(r[1].cast<TopicProgressModel>());
      _classroomNames
        ..clear()
        ..addEntries(r[2]
            .cast<ClassroomModel>()
            .where((c) => c.isActive && c.key != null)
            .map((c) => MapEntry(c.key!, c.name)));
    } finally {
      isLoading.value = false;
    }
  }

  int get activeTopics => _topics.where((t) => t.isActive).length;

  List<TopicProgressModel> get _done =>
      _progress.where((p) => p.isDone).toList();

  int get completed => _done.length;

  int get classroomsCovered =>
      _done.map((p) => p.classroomId).toSet().length;

  /// Average per-classroom coverage (done ÷ active topics), across classrooms
  /// that have started.
  int get avgCoverage {
    final total = activeTopics;
    if (total == 0) return 0;
    final rows = byClassroom;
    if (rows.isEmpty) return 0;
    final sum = rows.fold<double>(0, (s, r) => s + r.share);
    return ((sum / rows.length) * 100).round();
  }

  bool get isEmpty => _done.isEmpty;

  /// Per-classroom coverage, least-covered first (so laggards surface on top).
  List<CoverageRow> get byClassroom {
    final total = activeTopics;
    final doneByRoom = <String, int>{};
    for (final p in _done) {
      doneByRoom[p.classroomId] = (doneByRoom[p.classroomId] ?? 0) + 1;
    }
    final rows = doneByRoom.entries
        .map((e) => CoverageRow(
              classroom: _classroomNames[e.key] ?? '—',
              done: e.value,
              share: total == 0 ? 0 : (e.value / total).clamp(0, 1).toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.share.compareTo(b.share));
    return rows;
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

/// One classroom's syllabus coverage.
class CoverageRow {
  final String classroom;
  final int done;
  final double share;
  const CoverageRow({
    required this.classroom,
    required this.done,
    required this.share,
  });
}
