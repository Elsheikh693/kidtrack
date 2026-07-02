import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class TeacherWeeklyScheduleController extends GetxController {
  late final SessionService _session;

  final RxBool isLoading = true.obs;
  final RxString selectedDay = ''.obs;
  final Rx<ClassroomModel?> selectedClassroom = Rx<ClassroomModel?>(null);
  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxList<SubjectModel> allSubjects = <SubjectModel>[].obs;
  final RxList<ScheduleModel> currentSlots = <ScheduleModel>[].obs;

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
  String get teacherId => _session.userId ?? '';

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
    selectedDay.value = todayKey;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.wait([_loadMyClassrooms(), _loadAllSubjects()]);
    if (myClassrooms.isNotEmpty) {
      if (selectedClassroom.value == null) {
        selectedClassroom.value = myClassrooms.first;
      }
      await _loadSchedules();
    }
    _refreshCurrentSlots();
    isLoading.value = false;
  }

  void _refreshCurrentSlots() {
    final cId = selectedClassroom.value?.key ?? '';
    final day = selectedDay.value;
    final slots = List<ScheduleModel>.from(_scheduleMap[cId]?[day] ?? []);
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

  List<ScheduleModel> slotsForTodayInClassroom(String classroomId) {
    final slots = List<ScheduleModel>.from(
      _scheduleMap[classroomId]?[todayKey] ?? [],
    );
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    return slots;
  }

  SubjectModel? subjectById(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return allSubjects.firstWhere((s) => s.key == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadMyClassrooms() async {
    final uid = _session.userId;
    if (uid == null || nurseryId.isEmpty) return;

    final classrooms = <ClassroomModel>[];
    final loadedIds = <String>{};

    try {
      final staffSnap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/staff/$uid')
          .get();
      if (staffSnap.exists && staffSnap.value is Map) {
        final d = Map<String, dynamic>.from(staffSnap.value as Map);
        final idsToLoad = <String>{};
        final single = d['classroomId']?.toString() ?? '';
        if (single.isNotEmpty) idsToLoad.add(single);
        final multi = d['classroomIds'];
        if (multi is List) {
          for (final v in multi) {
            if (v != null) idsToLoad.add(v.toString());
          }
        } else if (multi is Map) {
          for (final v in multi.values) {
            if (v != null) idsToLoad.add(v.toString());
          }
        }
        for (final cId in idsToLoad) {
          try {
            final cSnap = await FirebaseDatabase.instance
                .ref('platform/$nurseryId/classrooms/$cId')
                .get();
            if (cSnap.exists && cSnap.value is Map) {
              classrooms.add(ClassroomModel.fromJson(
                Map<String, dynamic>.from(cSnap.value as Map),
                key: cId,
              ));
              loadedIds.add(cId);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    try {
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/classrooms')
          .orderByChild('teacherId')
          .equalTo(uid)
          .get();
      if (snap.exists && snap.value is Map) {
        for (final e in (snap.value as Map).entries) {
          final key = e.key.toString();
          if (e.value is Map && !loadedIds.contains(key)) {
            classrooms.add(ClassroomModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: key,
            ));
            loadedIds.add(key);
          }
        }
      }
    } catch (_) {}

    myClassrooms.value = classrooms..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _loadAllSubjects() async {
    try {
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/subjects')
          .get();
      if (!snap.exists || snap.value == null) return;
      allSubjects.value = (snap.value as Map)
          .entries
          .where((e) => e.value is Map)
          .map((e) => SubjectModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {}
  }

  Future<void> _loadSchedules() async {
    _scheduleMap.clear();
    for (final c in myClassrooms) {
      final cId = c.key ?? '';
      try {
        final snap = await FirebaseDatabase.instance
            .ref('platform/$nurseryId/schedules')
            .orderByChild('classroomId')
            .equalTo(cId)
            .get();
        if (!snap.exists || snap.value == null) continue;
        final dayMap = <String, List<ScheduleModel>>{};
        for (final e in (snap.value as Map).entries) {
          if (e.value is! Map) continue;
          final model = ScheduleModel.fromJson(
            Map<String, dynamic>.from(e.value as Map),
            key: e.key.toString(),
          );
          dayMap.putIfAbsent(model.day, () => []).add(model);
        }
        _scheduleMap[cId] = dayMap;
      } catch (_) {}
    }
  }

  Future<void> addSlot(ScheduleModel slot) async {
    try {
      final ref = FirebaseDatabase.instance
          .ref('platform/$nurseryId/schedules')
          .push();
      final newSlot = slot.copyWith(key: ref.key);
      await ref.set(newSlot.toJson());
      final cId = newSlot.classroomId;
      _scheduleMap.putIfAbsent(cId, () => {});
      _scheduleMap[cId]!.putIfAbsent(newSlot.day, () => []).add(newSlot);
      _refreshCurrentSlots();
    } catch (_) {}
  }

  Future<void> updateSlot(ScheduleModel slot) async {
    try {
      await FirebaseDatabase.instance
          .ref('platform/$nurseryId/schedules/${slot.key}')
          .update(slot.toJson());
      final cId = slot.classroomId;
      final list = _scheduleMap[cId]?[slot.day];
      if (list != null) {
        final idx = list.indexWhere((s) => s.key == slot.key);
        if (idx >= 0) list[idx] = slot;
      }
      _refreshCurrentSlots();
    } catch (_) {}
  }

  Future<void> deleteSlot(ScheduleModel slot) async {
    try {
      await FirebaseDatabase.instance
          .ref('platform/$nurseryId/schedules/${slot.key}')
          .remove();
      _scheduleMap[slot.classroomId]?[slot.day]
          ?.removeWhere((s) => s.key == slot.key);
      _refreshCurrentSlots();
    } catch (_) {}
  }

  @override
  Future<void> refresh() => _load();
}
