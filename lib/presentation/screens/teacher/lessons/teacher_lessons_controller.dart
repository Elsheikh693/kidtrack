import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/academic_topic/academic_topic_model.dart';
import '../../../../Data/models/classroom/classroom_model.dart';
import '../../../../Data/models/subject/subject_model.dart';
import '../../../../Data/models/topic_progress/topic_progress_model.dart';
import '../../../../Global/services/teacher_academic_service.dart';

class TeacherLessonsController extends GetxController {
  final _service = TeacherAcademicService();
  final _session = SessionService();

  final RxBool isLoading = true.obs;

  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxList<SubjectModel> mySubjects = <SubjectModel>[].obs;
  final RxList<AcademicTopicModel> topics = <AcademicTopicModel>[].obs;
  final RxMap<String, TopicProgressModel> progress = <String, TopicProgressModel>{}.obs;

  final Rx<ClassroomModel?> selectedClassroom = Rx<ClassroomModel?>(null);
  final Rx<SubjectModel?> selectedSubject = Rx<SubjectModel?>(null);

  final RxBool isToggling = false.obs;

  String get nurseryId => _session.nurseryId ?? '';

  int get doneCount => topics.where((t) => progress[t.key]?.isDone == true).length;
  int get totalCount => topics.length;

  @override
  void onInit() {
    super.onInit();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    isLoading.value = true;
    try {
      final assignment = await _service.loadAssignment();
      if (assignment == null || !assignment.isSetupDone) {
        isLoading.value = false;
        return;
      }

      // Load classrooms
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/classrooms')
          .get();
      if (snap.exists && snap.value is Map) {
        final data = snap.value as Map;
        myClassrooms.value = data.entries
            .where((e) =>
                e.value is Map &&
                assignment.classroomIds.contains(e.key.toString()))
            .map((e) => ClassroomModel.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  key: e.key.toString(),
                ))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }

      // Load subjects
      final subSnap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/subjects')
          .get();
      if (subSnap.exists && subSnap.value is Map) {
        final data = subSnap.value as Map;
        mySubjects.value = data.entries
            .where((e) =>
                e.value is Map &&
                assignment.subjectIds.contains(e.key.toString()))
            .map((e) => SubjectModel.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  key: e.key.toString(),
                ))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }

      // Auto-select first classroom and subject
      if (myClassrooms.isNotEmpty) selectedClassroom.value = myClassrooms.first;
      if (mySubjects.isNotEmpty) selectedSubject.value = mySubjects.first;

      await _loadTopics();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> selectClassroom(ClassroomModel c) async {
    selectedClassroom.value = c;
    await _loadTopics();
  }

  Future<void> selectSubject(SubjectModel s) async {
    selectedSubject.value = s;
    await _loadTopics();
  }

  Future<void> _loadTopics() async {
    final cId = selectedClassroom.value?.key;
    final sId = selectedSubject.value?.key;
    if (cId == null || sId == null) return;

    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.loadTopics(subjectId: sId),
        _service.loadTopicProgress(classroomId: cId, subjectId: sId),
      ]);
      topics.value = results[0] as List<AcademicTopicModel>;
      progress.value = results[1] as Map<String, TopicProgressModel>;
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> toggleTopic(String topicId) async {
    final cId = selectedClassroom.value?.key;
    final sId = selectedSubject.value?.key;
    if (cId == null || sId == null || isToggling.value) return;

    isToggling.value = true;
    final currentlyDone = progress[topicId]?.isDone == true;
    try {
      await _service.toggleTopicDone(
        classroomId: cId,
        subjectId: sId,
        topicId: topicId,
        isDone: !currentlyDone,
      );
      // Optimistic update
      if (!currentlyDone) {
        progress[topicId] = TopicProgressModel(
          nurseryId: nurseryId,
          classroomId: cId,
          teacherId: _session.userId ?? '',
          topicId: topicId,
          subjectId: sId,
          isDone: true,
          completedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        final existing = progress[topicId];
        if (existing != null) {
          progress[topicId] = existing.copyWith(isDone: false, completedAt: null);
        }
      }
      progress.refresh();
    } catch (_) {}
    isToggling.value = false;
  }

  Future<void> refresh() => _loadTopics();
}
