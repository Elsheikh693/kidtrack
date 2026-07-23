import '../../../../index/index_main.dart';

/// Manager-owned weekly timetable. The manager builds a schedule per classroom
/// (day + time + subject + assigned teacher + optional lesson topic). Teachers
/// read it (view-only) and start sessions from it; late-session detection is
/// anchored to these slots.
class ManagerScheduleController extends GetxController {
  late final SessionService _session;
  late final ScheduleParentService _scheduleService;
  late final ClassroomParentService _classroomService;
  late final SubjectParentService _subjectService;
  late final StaffParentService _staffService;
  late final LateSessionSettingsService lateSettings;

  final isLoading = true.obs;
  final isSaving = false.obs;

  final classrooms = <ClassroomModel>[].obs;
  final subjects = <SubjectModel>[].obs;
  final teachers = <StaffModel>[].obs;

  final selectedClassroom = Rxn<ClassroomModel>();
  final selectedDay = ''.obs;
  final currentSlots = <ScheduleModel>[].obs;

  // classroomId → day → slots
  final Map<String, Map<String, List<ScheduleModel>>> _scheduleMap = {};

  static const List<String> days = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  String get nurseryId => _session.nurseryId ?? '';

  static String get todayKey {
    switch (DateTime.now().weekday) {
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      default:
        return 'saturday';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _scheduleService = Get.find<ScheduleParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _subjectService = Get.find<SubjectParentService>();
    _staffService = Get.find<StaffParentService>();
    lateSettings = Get.find<LateSessionSettingsService>();
    lateSettings.load();
    selectedDay.value = todayKey;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    await Future.wait([_loadClassrooms(), _loadSubjects(), _loadTeachers()]);
    await _loadSchedules();
    if (selectedClassroom.value == null && classrooms.isNotEmpty) {
      selectedClassroom.value = classrooms.first;
    }
    _refreshCurrentSlots();
    isLoading.value = false;
  }

  Future<void> _loadClassrooms() async {
    final list = <ClassroomModel>[];
    await _classroomService.getAll(
      callBack: (data) {
        for (final c in data) {
          if (c == null) continue;
          // Manager sees only her branch's classrooms (shared / all-branch
          // classrooms stay visible via seesAnyBranch semantics).
          if (_session.seesAnyBranch(c.scopeBranches)) list.add(c);
        }
      },
    );
    list.sort((a, b) => a.name.compareTo(b.name));
    classrooms.value = list;
  }

  Future<void> _loadSubjects() async {
    final list = <SubjectModel>[];
    await _subjectService.getAll(
      callBack: (data) {
        for (final s in data) {
          if (s != null) list.add(s);
        }
      },
    );
    list.sort((a, b) => a.name.compareTo(b.name));
    subjects.value = list;
  }

  Future<void> _loadTeachers() async {
    final list = <StaffModel>[];
    await _staffService.getAll(
      callBack: (data) {
        for (final s in data) {
          if (s == null) continue;
          if (s.role != UserType.teacher) continue;
          if (!_session.seesBranch(s.branchId)) continue;
          list.add(s);
        }
      },
    );
    list.sort((a, b) => a.name.compareTo(b.name));
    teachers.value = list;
  }

  Future<void> _loadSchedules() async {
    _scheduleMap.clear();
    await _scheduleService.getAll(
      callBack: (data) {
        for (final s in data) {
          if (s == null) continue;
          _scheduleMap
              .putIfAbsent(s.classroomId, () => {})
              .putIfAbsent(s.day, () => [])
              .add(s);
        }
      },
    );
  }

  void _refreshCurrentSlots() {
    final cId = selectedClassroom.value?.key ?? '';
    final slots =
        List<ScheduleModel>.from(_scheduleMap[cId]?[selectedDay.value] ?? []);
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    currentSlots.value = slots;
  }

  void selectDay(String day) {
    selectedDay.value = day;
    _refreshCurrentSlots();
  }

  void selectClassroom(ClassroomModel classroom) {
    selectedClassroom.value = classroom;
    _refreshCurrentSlots();
  }

  SubjectModel? subjectById(String? id) {
    if (id == null || id.isEmpty) return null;
    return subjects.firstWhereOrNull((s) => s.key == id);
  }

  StaffModel? teacherById(String? id) {
    if (id == null || id.isEmpty) return null;
    return teachers.firstWhereOrNull((t) => t.uid == id);
  }

  String teacherName(String? id) => teacherById(id)?.name ?? '';

  String subjectName(String? id) => subjectById(id)?.name ?? '';

  // ── Mutations ───────────────────────────────────────────────────────────────

  Future<void> saveSlot(ScheduleModel slot) async {
    isSaving.value = true;
    final isEdit = slot.key != null && slot.key!.isNotEmpty;
    var ok = false;
    if (isEdit) {
      await _scheduleService.update(
        item: slot,
        callBack: (s) => ok = s == ResponseStatus.success,
      );
    } else {
      // A key MUST be generated client-side: BaseService.add writes to
      // `schedules/{key}` — an empty key would PATCH the whole schedules node.
      final keyed =
          slot.copyWith(key: 'slot_${DateTime.now().millisecondsSinceEpoch}');
      await _scheduleService.add(
        item: keyed,
        callBack: (s) => ok = s == ResponseStatus.success,
      );
    }
    isSaving.value = false;
    if (ok) {
      await _loadSchedules();
      _refreshCurrentSlots();
      // Keep the manager's live late-session card in sync with edits.
      if (Get.isRegistered<LateSessionMonitorService>()) {
        Get.find<LateSessionMonitorService>().refresh();
      }
      Loader.showSuccess('schedule_save_success'.tr);
    } else {
      Loader.showError('schedule_save_error'.tr);
    }
  }

  Future<void> deleteSlot(ScheduleModel slot) async {
    if (slot.key == null || slot.key!.isEmpty) return;
    isSaving.value = true;
    var ok = false;
    await _scheduleService.delete(
      id: slot.key!,
      callBack: (s) => ok = s == ResponseStatus.success,
    );
    isSaving.value = false;
    if (ok) {
      _scheduleMap[slot.classroomId]?[slot.day]
          ?.removeWhere((s) => s.key == slot.key);
      _refreshCurrentSlots();
      if (Get.isRegistered<LateSessionMonitorService>()) {
        Get.find<LateSessionMonitorService>().refresh();
      }
      Loader.showSuccess('schedule_delete_success'.tr);
    } else {
      Loader.showError('schedule_save_error'.tr);
    }
  }

  Future<void> refreshData() => load();

  /// Reached from the home quick-links, so "back" returns to the dashboard tab.
  void goBack() => Get.find<MainPageViewModel>().changePage(0);
}
