import '../../../../index/index_main.dart';
import '../../../parentControllers/services/classroom_parent_service.dart';

/// Drives the media-approval feature: the list of today's activities that have
/// photos awaiting review, and the per-activity approve / reject / re-audience
/// actions. Visible only to users with [SessionService.canReviewPhotos].
class MediaApprovalController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _service;
  late final ClassroomParentService _classroomSvc;

  final pendingActivities = <ClassroomActivityModel>[].obs;
  final isLoading = true.obs;

  // classroomId → active children (loaded once, used for audience editing).
  final _childrenByClassroom = <String, List<ChildModel>>{};
  // classroomId → display name (for the pending cards).
  final _classroomNames = <String, String>{};

  StreamSubscription<List<ClassroomActivityModel>>? _sub;

  String get _nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = TeacherActivityService();
    _classroomSvc = ClassroomParentService();
    _start();
  }

  Future<void> _start() async {
    isLoading.value = true;
    final ids = await _resolveClassroomIds();
    if (ids.isEmpty) {
      pendingActivities.clear();
      isLoading.value = false;
      return;
    }
    _sub?.cancel();
    _sub = _service
        .watchPendingActivitiesForClassrooms(_nurseryId, ids)
        .listen((list) {
      pendingActivities.assignAll(list);
      isLoading.value = false;
    });
    // Preload children so the audience picker opens instantly.
    for (final id in ids) {
      _service
          .loadChildren(_nurseryId, id)
          .then((c) => _childrenByClassroom[id] = c);
    }
  }

  /// Classrooms this reviewer is responsible for: their branch (all branches
  /// for an owner) and within their shift scope.
  Future<List<String>> _resolveClassroomIds() async {
    final result = <String>[];
    await _classroomSvc.getAll(callBack: (list) {
      final branchId = _session.branchId;
      for (final c in list.whereType<ClassroomModel>()) {
        final id = c.key ?? '';
        if (id.isEmpty) continue;
        if (branchId != null &&
            branchId.isNotEmpty &&
            !c.isAllBranches &&
            !c.branchIds.contains(branchId)) {
          continue;
        }
        if (!_session.seesShift(c.shift)) continue;
        _classroomNames[id] = c.name;
        result.add(id);
      }
    });
    return result;
  }

  String classroomName(String classroomId) =>
      _classroomNames[classroomId] ?? '';

  ClassroomActivityModel? activityByKey(String? key) {
    if (key == null) return null;
    return pendingActivities.firstWhereOrNull((a) => a.key == key);
  }

  List<ChildModel> childrenFor(String classroomId) =>
      _childrenByClassroom[classroomId] ?? const [];

  int get totalPendingPhotos =>
      pendingActivities.fold(0, (acc, a) => acc + a.pendingPhotoCount);

  /// Approve = publish: every still-pending photo of the activity flips to
  /// approved together and becomes visible to guardians.
  Future<void> approveActivity(ClassroomActivityModel activity) async {
    final pendingIds = activity.photos.entries
        .where((e) => !e.value.isApproved)
        .map((e) => e.key)
        .toList();
    if (pendingIds.isEmpty || activity.key == null) return;
    Loader.show();
    try {
      await _service.approveActivityPhotos(
        nurseryId: _nurseryId,
        classroomId: activity.classroomId,
        activityId: activity.key!,
        photoIds: pendingIds,
        approvedBy: _session.userId ?? '',
      );
      Loader.showSuccess('media_approve_success'.tr);
      Get.back();
    } catch (_) {
      Loader.showError('media_approve_error'.tr);
    }
  }

  /// Remove a bad photo — deletes it from storage + the activity node.
  Future<void> rejectPhoto(
      ClassroomActivityModel activity, String photoId) async {
    if (activity.key == null) return;
    await _service.deleteActivityPhoto(
      nurseryId: _nurseryId,
      classroomId: activity.classroomId,
      activityId: activity.key!,
      photoId: photoId,
    );
  }

  /// Reviewer overrides who a photo is for. Empty list ⇒ classroom-wide.
  Future<void> setPhotoAudience(
    ClassroomActivityModel activity,
    String photoId,
    List<String> childIds,
  ) async {
    if (activity.key == null) return;
    await _service.updatePhotoAudience(
      nurseryId: _nurseryId,
      classroomId: activity.classroomId,
      activityId: activity.key!,
      photoId: photoId,
      audienceType:
          childIds.isEmpty ? AudienceType.classroom : AudienceType.children,
      targetChildren: childIds,
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
