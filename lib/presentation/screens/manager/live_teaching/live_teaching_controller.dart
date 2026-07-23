import '../../../../index/index_main.dart';
import 'models/teaching_slice.dart';
import 'detail/teacher_today_view.dart';

/// Live snapshot for the manager home donut: which classes are in session right
/// now and what each is being taught. Read-only — it reshapes the running
/// [ClassroomActivityModel]s into per-class [TeachingSlice]s and deep-links each
/// into the teacher's day timeline.
class LiveTeachingController extends GetxController {
  final isLoading = true.obs;
  final slices = <TeachingSlice>[].obs;

  final _session = SessionService();
  final _activitySvc = TeacherActivityService();
  late final ClassroomParentService _classroomSvc;
  late final StaffParentService _staffSvc;

  final _classroomNames = <String, String>{};
  final _teacherNames = <String, String>{};
  final _teacherPhotos = <String, String?>{};

  // Accent by mode, so a whole-class حصة and a subset نشاط read differently at a
  // glance regardless of how many are running.
  static const _sessionColor = AppColors.activityBlue;
  static const _activityColor = AppColors.activityPurple;

  String get nurseryId => _session.nurseryId ?? '';
  String get branchId => _session.branchId ?? '';

  int get activeCount => slices.length;

  StreamSubscription<List<ClassroomActivityModel>>? _activeSub;

  @override
  void onInit() {
    super.onInit();
    _classroomSvc = Get.find<ClassroomParentService>();
    _staffSvc = Get.find<StaffParentService>();
    loadData();
  }

  /// Loads the (stable) classroom + teacher lookups once, then subscribes to a
  /// live stream of running activities so the card updates the moment a teacher
  /// starts or ends a session — no manual refresh needed.
  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadClassrooms(), _loadTeachers()]);
    _subscribeActive();
  }

  void _subscribeActive() {
    _activeSub?.cancel();
    final classroomIds = _classroomNames.keys.toList();
    _activeSub = _activitySvc
        .watchActiveForClassrooms(nurseryId, classroomIds)
        .listen((active) {
      _rebuildSlices(active);
      isLoading.value = false;
    });
  }

  Future<void> _loadClassrooms() async {
    _classroomNames.clear();
    await _classroomSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ClassroomModel>()) {
        if ((c.isAllBranches || c.branchIds.contains(branchId)) &&
            c.isActive &&
            c.key != null) {
          _classroomNames[c.key!] = c.name;
        }
      }
    });
  }

  Future<void> _loadTeachers() async {
    _teacherNames.clear();
    _teacherPhotos.clear();
    await _staffSvc.getAll(callBack: (list) {
      for (final s in list.whereType<StaffModel>()) {
        if (s.branchId == branchId && s.isActive && s.key != null) {
          _teacherNames[s.key!] = s.name;
          _teacherPhotos[s.key!] = s.profileImage;
        }
      }
    });
  }

  /// Reshapes the live set of running activities into display slices. Every
  /// running session shows as its own card — a whole-class "حصة" and a subset
  /// "نشاط" in the same room appear side by side rather than one hiding the
  /// other.
  void _rebuildSlices(List<ClassroomActivityModel> active) {
    // Classrooms are shared across branches, so an active class run by another
    // branch's teacher would otherwise leak in (as an "unknown teacher"). The
    // uploader's branch is the reliable signal: keep only in-branch teachers.
    final entries = active
        .where((a) => _teacherNames.containsKey(a.teacherId))
        .toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final built = <TeachingSlice>[];
    for (final a in entries) {
      final subject = (a.subjectName ?? '').trim();
      final title = a.title.trim();
      built.add(TeachingSlice(
        classroomId: a.classroomId,
        className:
            _classroomNames[a.classroomId] ?? 'live_teaching_class'.tr,
        subjectLabel:
            subject.isNotEmpty ? subject : 'live_teaching_activity'.tr,
        activityTitle: title,
        teacherId: a.teacherId,
        teacherName: _teacherNames[a.teacherId] ?? 'tr_unknown_teacher'.tr,
        teacherPhoto: _teacherPhotos[a.teacherId],
        startedAt: a.startedAt,
        isActivityMode: a.isActivityMode,
        participantCount: a.childIds.length,
        color: a.isActivityMode ? _activityColor : _sessionColor,
      ));
    }
    slices.assignAll(built);
  }

  /// Open the tapped teacher's day timeline (today's activities, filterable by
  /// class and subject).
  void openTeacherDay(TeachingSlice slice) {
    Get.find<TeacherTodayController>().open(
      teacherId: slice.teacherId,
      name: slice.teacherName,
      photo: slice.teacherPhoto,
      color: slice.color,
    );
    Get.to(
      () => const TeacherTodayView(),
      transition: Transition.cupertino,
    );
  }

  @override
  void onClose() {
    _activeSub?.cancel();
    super.onClose();
  }
}
