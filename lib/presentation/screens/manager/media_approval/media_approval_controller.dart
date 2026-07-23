import '../../../../index/index_main.dart';
import '../../../parentControllers/services/classroom_parent_service.dart';

/// Drives the media-approval feature: today's classroom activities plus nursery
/// events that have photos awaiting review, and the per-item approve / reject /
/// re-audience actions. Visible only to users with
/// [SessionService.canReviewPhotos].
class MediaApprovalController extends GetxController {
  late final SessionService _session;
  late final TeacherActivityService _service;
  late final ClassroomParentService _classroomSvc;
  late final EventService _eventService;
  late final ChildParentService _childSvc;
  late final StaffParentService _staffSvc;
  late final FeedService _feed;

  final pendingActivities = <ClassroomActivityModel>[].obs;
  final pendingEvents = <NurseryEventModel>[].obs;
  final isLoading = true.obs;

  // teacherId (staff key) → their branch, so photos can be scoped to the
  // reviewer's branch by their UPLOADER: shared/all-branch classrooms otherwise
  // mix both branches' activities into the same review list.
  final _teacherBranch = <String, String>{};

  // classroomId → active children (loaded once, used for audience editing).
  final _childrenByClassroom = <String, List<ChildModel>>{};
  // classroomId → display name (for the pending cards).
  final _classroomNames = <String, String>{};
  // All active children in the reviewer's branch — the event audience picker.
  final _branchChildren = <ChildModel>[];

  StreamSubscription<List<ClassroomActivityModel>>? _sub;
  StreamSubscription<List<NurseryEventModel>>? _eventSub;

  String get _nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = TeacherActivityService();
    _classroomSvc = ClassroomParentService();
    _eventService = EventService();
    _childSvc = ChildParentService();
    _staffSvc = StaffParentService();
    _feed = FeedService();
    _start();
    _startEvents();
    _loadBranchChildren();
  }

  Future<void> _start() async {
    isLoading.value = true;
    // Loaded before the stream so the very first emission is already scoped.
    await _loadTeacherBranches();
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
      pendingActivities.assignAll(list.where(_inReviewerBranch).toList());
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

  /// Maps every staff member to their branch so a photo can be scoped by its
  /// uploader. Classrooms are shared across branches and legacy activities carry
  /// no `branchId`, so the uploader's staff branch is the reliable signal.
  Future<void> _loadTeacherBranches() async {
    await _staffSvc.getAll(callBack: (list) {
      _teacherBranch.clear();
      for (final s in list.whereType<StaffModel>()) {
        if (s.key != null) _teacherBranch[s.key!] = s.branchId ?? '';
      }
    });
  }

  /// A pending activity belongs to the reviewer's branch when its stamped
  /// `branchId` (or, for legacy records, its uploader's branch) matches. An
  /// owner reviewing all branches has an empty branch and sees everything.
  bool _inReviewerBranch(ClassroomActivityModel a) {
    final entityBranch = (a.branchId != null && a.branchId!.isNotEmpty)
        ? a.branchId
        : _teacherBranch[a.teacherId];
    return SessionService.branchVisible(_session.branchId, entityBranch);
  }

  String classroomName(String classroomId) =>
      _classroomNames[classroomId] ?? '';

  ClassroomActivityModel? activityByKey(String? key) {
    if (key == null) return null;
    return pendingActivities.firstWhereOrNull((a) => a.key == key);
  }

  List<ChildModel> childrenFor(String classroomId) =>
      _childrenByClassroom[classroomId] ?? const [];

  // ── Events ────────────────────────────────────────────────────────────────

  /// Nursery events (in the reviewer's branch) with photos awaiting review.
  void _startEvents() {
    _eventSub?.cancel();
    _eventSub = _eventService.watchPendingEvents().listen((list) {
      pendingEvents.assignAll(
        list.where((e) => _session.seesBranch(e.branchId)).toList(),
      );
    });
  }

  /// The event audience picker targets any active child in the reviewer's
  /// branch (an event is nursery-wide, not classroom-scoped).
  Future<void> _loadBranchChildren() async {
    await _childSvc.getAll(callBack: (list) {
      _branchChildren
        ..clear()
        ..addAll(list.whereType<ChildModel>().where((c) =>
            c.status == 'active' && _session.seesBranch(c.branchId)));
      _branchChildren.sort((a, b) => a.fullName.compareTo(b.fullName));
    });
  }

  List<ChildModel> get branchChildren => _branchChildren;

  NurseryEventModel? eventByKey(String? id) {
    if (id == null) return null;
    return pendingEvents.firstWhereOrNull((e) => e.id == id);
  }

  /// Approve = publish every still-pending photo of the event together, then
  /// publish/refresh a public GALLERY post in the social feed pinned for
  /// [bannerDays] days (0 = posted but not pinned).
  Future<void> approveEvent(
    NurseryEventModel event, {
    int bannerDays = 0,
  }) async {
    final pendingIds = event.photos.entries
        .where((e) => !e.value.isApproved)
        .map((e) => e.key)
        .toList();
    if (pendingIds.isEmpty) return;
    Loader.show();
    try {
      await _eventService.approveEventPhotos(
        eventId: event.id,
        photoIds: pendingIds,
        approvedBy: _session.userId ?? '',
        bannerDays: bannerDays,
      );
      await _publishEventGalleryPost(event, bannerDays);
      Loader.showSuccess('media_approve_success'.tr);
      Get.back();
    } catch (_) {
      Loader.showError('media_approve_error'.tr);
    }
  }

  /// Creates (or refreshes on re-approval) the event's social-feed gallery post.
  Future<void> _publishEventGalleryPost(
    NurseryEventModel event,
    int bannerDays,
  ) async {
    final urls = event.allPhotoUrls;
    if (urls.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final pinnedUntil = bannerDays > 0 ? now + bannerDays * 86400000 : null;
    final existing = event.photosPostId;
    if (existing != null && existing.isNotEmpty) {
      await _feed.updatePostMedia(
        postId: existing,
        photoUrls: urls,
        isPinned: bannerDays > 0,
        pinnedUntil: pinnedUntil,
      );
    } else {
      final postId = await _feed.createPostRaw(
        text: event.title,
        category: PostCategory.gallery,
        isPinned: bannerDays > 0,
        pinnedUntil: pinnedUntil,
        // Public — visible to all guardians (locked decision), so no branch scope.
        branchIds: const [],
        photoUrls: urls,
        authorName: _session.currentUser?.displayName,
      );
      if (postId != null) {
        await _eventService.setPhotosPostId(event.id, postId);
      }
    }
  }

  Future<void> rejectEventPhoto(NurseryEventModel event, String photoId) async {
    await _eventService.deleteEventPhoto(eventId: event.id, photoId: photoId);
  }

  Future<void> setEventPhotoAudience(
    NurseryEventModel event,
    String photoId,
    List<String> childIds,
  ) async {
    await _eventService.updateEventPhotoAudience(
      eventId: event.id,
      photoId: photoId,
      audienceType:
          childIds.isEmpty ? AudienceType.classroom : AudienceType.children,
      targetChildren: childIds,
    );
  }

  int get totalPendingPhotos =>
      pendingActivities.fold(0, (acc, a) => acc + a.pendingPhotoCount) +
      pendingEvents.fold(0, (acc, e) => acc + e.pendingPhotoCount);

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
    _eventSub?.cancel();
    super.onClose();
  }
}
