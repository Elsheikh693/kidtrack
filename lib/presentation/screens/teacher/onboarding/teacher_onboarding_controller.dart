import 'package:flutter/material.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/classroom/classroom_model.dart';
import '../../../../Data/models/subject/subject_model.dart';
import '../../../../Data/models/teacher_assignment/teacher_assignment_model.dart';
import '../../../../Global/services/teacher_academic_service.dart';

class TeacherOnboardingController extends GetxController {
  TeacherOnboardingController({this.editMode = false});

  /// When true, the screen edits an existing academic profile (opened from
  /// settings) instead of running the first-login wizard.
  final bool editMode;

  final _service = TeacherAcademicService();
  final _session = SessionService();

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  // Raw data
  final RxList<ClassroomModel> allClassrooms = <ClassroomModel>[].obs;
  final RxList<SubjectModel> allSubjects = <SubjectModel>[].obs;

  // Step 1: selected classrooms (ordered list for matrix row order)
  final RxList<String> selectedClassroomIds = <String>[].obs;

  // Step 2: matrix — classroomId → Set<subjectId>
  final RxMap<String, Set<String>> matrix = <String, Set<String>>{}.obs;

  List<ClassroomModel> get selectedClassrooms => allClassrooms
      .where((c) => selectedClassroomIds.contains(c.key))
      .toList();

  bool isClassroomSelected(String id) => selectedClassroomIds.contains(id);

  bool isMatrixChecked(String classroomId, String subjectId) =>
      matrix[classroomId]?.contains(subjectId) ?? false;

  int get totalAssignments =>
      matrix.values.fold(0, (sum, set) => sum + set.length);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final results = await Future.wait([
      _service.loadClassrooms(),
      _service.loadSubjects(),
    ]);
    allClassrooms.value = results[0] as List<ClassroomModel>;
    allSubjects.value = results[1] as List<SubjectModel>;

    if (editMode) {
      final existing = await _service.loadAssignment();
      if (existing != null) {
        selectedClassroomIds.value = existing.classroomIds
            .where((id) => allClassrooms.any((c) => c.key == id))
            .toList();
        final m = <String, Set<String>>{};
        for (final cId in selectedClassroomIds) {
          m[cId] = existing.subjectsForClassroom(cId).toSet();
        }
        matrix.value = m;
      }
    }

    isLoading.value = false;
  }

  // ── Step 1 ──────────────────────────────────────────────────────────────────

  void toggleClassroom(String id) {
    if (selectedClassroomIds.contains(id)) {
      selectedClassroomIds.remove(id);
      matrix.remove(id);
      matrix.refresh();
    } else {
      selectedClassroomIds.add(id);
      matrix[id] = {};
      matrix.refresh();
    }
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (selectedClassroomIds.isEmpty) {
        Get.snackbar('تنبيه', 'اختاري فصلاً واحداً على الأقل',
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            duration: const Duration(seconds: 2));
        return;
      }
      currentStep.value = 1;
      pageController.animateToPage(1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic);
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic);
    }
  }

  // ── Step 2: Matrix ───────────────────────────────────────────────────────────

  void toggleCell(String classroomId, String subjectId) {
    final set = matrix[classroomId] ?? {};
    if (set.contains(subjectId)) {
      set.remove(subjectId);
    } else {
      set.add(subjectId);
    }
    matrix[classroomId] = set;
    matrix.refresh();
  }

  void toggleEntireColumn(String subjectId) {
    final allChecked = selectedClassroomIds
        .every((cId) => matrix[cId]?.contains(subjectId) == true);
    for (final cId in selectedClassroomIds) {
      final set = matrix[cId] ?? {};
      if (allChecked) {
        set.remove(subjectId);
      } else {
        set.add(subjectId);
      }
      matrix[cId] = set;
    }
    matrix.refresh();
  }

  void toggleEntireRow(String classroomId) {
    final set = matrix[classroomId] ?? {};
    final allChecked = allSubjects.every((s) => set.contains(s.key));
    if (allChecked) {
      matrix[classroomId] = {};
    } else {
      matrix[classroomId] = allSubjects.map((s) => s.key ?? '').toSet();
    }
    matrix.refresh();
  }

  bool isColumnAllChecked(String subjectId) => selectedClassroomIds.isNotEmpty &&
      selectedClassroomIds
          .every((cId) => matrix[cId]?.contains(subjectId) == true);

  bool isRowAllChecked(String classroomId) => allSubjects.isNotEmpty &&
      allSubjects
          .every((s) => matrix[classroomId]?.contains(s.key) == true);

  // ── Save ─────────────────────────────────────────────────────────────────────

  Future<void> saveAndFinish() async {
    if (totalAssignments == 0) {
      Get.snackbar('تنبيه', 'حددي مادة واحدة على الأقل في الجدول',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800);
      return;
    }
    isSaving.value = true;
    try {
      final entries = <AssignmentEntry>[];
      for (final cId in selectedClassroomIds) {
        for (final sId in matrix[cId] ?? {}) {
          if (cId.isNotEmpty && sId.isNotEmpty) {
            entries.add(AssignmentEntry(classroomId: cId, subjectId: sId));
          }
        }
      }

      final model = TeacherAssignmentModel(
        teacherId: _session.userId ?? '',
        nurseryId: _session.nurseryId ?? '',
        branchId: _session.branchId ?? '',
        isSetupDone: true,
        assignments: entries,
      );

      await _service.saveAssignment(model);
      await SetupLocalCheck.markDone(_session.userId ?? '');
      if (editMode) {
        Get.back();
        Get.snackbar('تم الحفظ', 'تم تحديث ملفك الأكاديمي',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: const Duration(seconds: 2));
      } else {
        Get.offAllNamed(mainView);
      }
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر الحفظ، حاولي مرة أخرى',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
