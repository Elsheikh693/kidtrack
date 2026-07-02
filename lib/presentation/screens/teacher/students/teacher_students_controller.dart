import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/child/child_model.dart';
import '../../../../Data/models/classroom/classroom_model.dart';

class TeacherStudentsController extends GetxController {
  final _session = SessionService();

  final RxList<ChildModel> allChildren = <ChildModel>[].obs;
  final RxList<ChildModel> filtered = <ChildModel>[].obs;
  final RxList<ClassroomModel> myClassrooms = <ClassroomModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedClassroomId = ''.obs; // '' = all
  final RxMap<String, String> todayAttendance = <String, String>{}.obs;

  String get nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
    debounce(searchQuery, (_) => _filter(),
        time: const Duration(milliseconds: 300));
    ever(selectedClassroomId, (_) => _filter());
  }

  Future<void> _load() async {
    isLoading.value = true;
    await _loadMyClassrooms();
    if (myClassrooms.isNotEmpty) {
      await Future.wait([_loadChildren(), _loadTodayAttendance()]);
    }
    _filter();
    isLoading.value = false;
  }

  Future<void> _loadMyClassrooms() async {
    final uid = _session.userId;
    if (uid == null || nurseryId.isEmpty) return;

    final classrooms = <ClassroomModel>[];
    final loadedIds = <String>{};

    // Step 1: Read from staff node directly (always reliable)
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
          for (final v in multi) { if (v != null) idsToLoad.add(v.toString()); }
        } else if (multi is Map) {
          for (final v in multi.values) { if (v != null) idsToLoad.add(v.toString()); }
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

    // Step 2: Try teacherId query as supplement
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
            final c = ClassroomModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: key,
            );
            classrooms.add(c);
            loadedIds.add(key);
          }
        }
      }
    } catch (_) {}

    myClassrooms.value = classrooms..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _loadChildren() async {
    try {
      final children = <ChildModel>[];
      for (final c in myClassrooms) {
        final snap = await FirebaseDatabase.instance
            .ref('platform/$nurseryId/children')
            .orderByChild('classroomId')
            .equalTo(c.key ?? '')
            .get();
        if (!snap.exists || snap.value == null) continue;
        final data = snap.value as Map? ?? {};
        final list = data.entries
            .where((e) => e.value is Map)
            .map((e) => ChildModel.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  key: e.key.toString(),
                ))
            .where((child) => child.status == 'active')
            .toList();
        children.addAll(list);
      }
      children.sort((a, b) => a.firstName.compareTo(b.firstName));
      allChildren.value = children;
    } catch (_) {}
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final today = _todayKey();
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/childAttendance')
          .orderByChild('date')
          .equalTo(today)
          .get();
      if (!snap.exists || snap.value == null) {
        todayAttendance.value = {};
        return;
      }
      final data = snap.value as Map? ?? {};
      final map = <String, String>{};
      for (final e in data.entries) {
        if (e.value is Map) {
          final v = e.value as Map;
          final cId = v['childId']?.toString();
          final st = v['status']?.toString() ?? 'absent';
          if (cId != null) map[cId] = st;
        }
      }
      todayAttendance.value = map;
    } catch (_) {}
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    final cId = selectedClassroomId.value;

    var list = allChildren.toList();

    if (cId.isNotEmpty) {
      list = list.where((c) => c.classroomId == cId).toList();
    }

    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.firstName.toLowerCase().contains(q) ||
              c.lastName.toLowerCase().contains(q))
          .toList();
    }

    filtered.value = list;
  }

  void search(String v) => searchQuery.value = v;

  void selectClassroom(String id) {
    selectedClassroomId.value = selectedClassroomId.value == id ? '' : id;
  }

  String attendanceStatus(String childId) =>
      todayAttendance[childId] ?? 'unknown';

  String classroomName(String? classroomId) {
    if (classroomId == null) return '';
    for (final c in myClassrooms) {
      if (c.key == classroomId) return c.name;
    }
    return '';
  }

  Future<void> refresh() => _load();

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
