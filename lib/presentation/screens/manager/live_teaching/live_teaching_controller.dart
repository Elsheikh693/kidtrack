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

  // Categorical rail — one color per class in session, cycled when they run out.
  static const _palette = <Color>[
    AppColors.activityBlue,
    AppColors.activityAmberBrand,
    AppColors.activityPurple,
    AppColors.activityGreen,
    AppColors.activityOrange,
    AppColors.activityRed,
  ];

  String get nurseryId => _session.nurseryId ?? '';
  String get branchId => _session.branchId ?? '';

  int get activeCount => slices.length;

  @override
  void onInit() {
    super.onInit();
    _classroomSvc = Get.find<ClassroomParentService>();
    _staffSvc = Get.find<StaffParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadClassrooms(), _loadTeachers()]);
    await _buildSlices();
    isLoading.value = false;
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

  Future<void> _buildSlices() async {
    final classroomIds = _classroomNames.keys.toList();
    final active =
        await _activitySvc.getActiveForClassrooms(nurseryId, classroomIds);

    // One slice per class in session — if co-teachers each run something, the
    // most recently started activity represents the class.
    final latestByClass = <String, ClassroomActivityModel>{};
    for (final a in active) {
      final cur = latestByClass[a.classroomId];
      if (cur == null || a.startedAt > cur.startedAt) {
        latestByClass[a.classroomId] = a;
      }
    }

    final entries = latestByClass.values.toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final built = <TeachingSlice>[];
    for (var i = 0; i < entries.length; i++) {
      final a = entries[i];
      final subject = (a.subjectName ?? '').trim();
      final title = a.title.trim();
      final label = subject.isNotEmpty
          ? subject
          : (title.isNotEmpty ? title : 'live_teaching_activity'.tr);
      built.add(TeachingSlice(
        classroomId: a.classroomId,
        className:
            _classroomNames[a.classroomId] ?? 'live_teaching_class'.tr,
        subjectLabel: label,
        teacherId: a.teacherId,
        teacherName: _teacherNames[a.teacherId] ?? 'tr_unknown_teacher'.tr,
        teacherPhoto: _teacherPhotos[a.teacherId],
        startedAt: a.startedAt,
        color: _palette[i % _palette.length],
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
}
