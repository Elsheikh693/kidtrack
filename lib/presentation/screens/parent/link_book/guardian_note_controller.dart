import '../../../../index/index_main.dart';

/// Holds the guardian's own session notes for the ACTIVE child and lets the
/// Link Book add / edit / delete them. Reloads automatically when the parent
/// switches child. One editable note per session (deterministic key).
class GuardianNoteController extends GetxController {
  final _session = SessionService();
  late final GuardianNoteParentService _service;

  /// activityId → the guardian's note for that session.
  final notesByActivity = <String, GuardianNoteModel>{}.obs;
  final isLoading = false.obs;

  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<GuardianNoteParentService>();
    loadForActiveChild();
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) => loadForActiveChild(),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  GuardianNoteModel? noteFor(String? activityId) =>
      activityId == null ? null : notesByActivity[activityId];

  Future<void> loadForActiveChild() async {
    final childId = Get.find<ActiveChildService>().childId.value;
    if (childId.isEmpty) {
      notesByActivity.clear();
      return;
    }
    isLoading.value = true;
    try {
      final list = await _service.getForChild(childId);
      notesByActivity.assignAll({
        for (final n in list)
          if (n.activityId.isNotEmpty) n.activityId: n,
      });
    } catch (_) {
      // keep whatever is cached
    }
    isLoading.value = false;
  }

  /// Create or update the guardian's note for [item]'s session. The day anchor
  /// is derived from the session's own start time.
  Future<void> saveNote({
    required DayTimelineItem item,
    required String content,
  }) async {
    final text = content.trim();
    final activityId = item.activityId ?? '';
    final svc = Get.find<ActiveChildService>();
    final childId = svc.childId.value;
    final nurseryId = _session.nurseryId ?? '';
    if (activityId.isEmpty || childId.isEmpty || nurseryId.isEmpty) {
      Loader.showError('guardian_note_error'.tr);
      return;
    }
    if (text.isEmpty) return;

    final key = GuardianNoteModel.buildKey(activityId, childId);
    final existing = notesByActivity[activityId];

    final model = GuardianNoteModel(
      key: key,
      nurseryId: nurseryId,
      childId: childId,
      childName: svc.childName.value,
      classroomId: item.classroomId ?? svc.classroomId.value,
      classroomName: '',
      activityId: activityId,
      subjectName: item.subjectName,
      activityTitle: item.title,
      activityStartedAt: item.startedAt,
      guardianId: _session.userId ?? '',
      guardianName: _session.currentUser?.displayName ?? '',
      content: text,
      dayKey: _startOfDay(item.startedAt),
      createdAt: existing?.createdAt,
    );

    Loader.show();
    try {
      final result = await _upsert(model);
      if (result == ResponseStatus.success) {
        notesByActivity[activityId] = model;
        Loader.showSuccess('guardian_note_saved'.tr);
      } else {
        Loader.showError('guardian_note_error'.tr);
      }
    } catch (_) {
      Loader.showError('guardian_note_error'.tr);
    }
  }

  Future<void> deleteNote(String activityId) async {
    final note = notesByActivity[activityId];
    final id = note?.key;
    if (id == null || id.isEmpty) return;
    Loader.show();
    try {
      final result = await _delete(id);
      if (result == ResponseStatus.success) {
        notesByActivity.remove(activityId);
        Loader.showSuccess('guardian_note_deleted'.tr);
      } else {
        Loader.showError('guardian_note_error'.tr);
      }
    } catch (_) {
      Loader.showError('guardian_note_error'.tr);
    }
  }

  static int _startOfDay(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms > 0 ? ms : _nowMs());
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  static int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  Future<ResponseStatus> _upsert(GuardianNoteModel model) async {
    ResponseStatus status = ResponseStatus.error;
    await _service.upsert(item: model, callBack: (s) => status = s);
    return status;
  }

  Future<ResponseStatus> _delete(String id) async {
    ResponseStatus status = ResponseStatus.error;
    await _service.delete(id: id, callBack: (s) => status = s);
    return status;
  }
}
