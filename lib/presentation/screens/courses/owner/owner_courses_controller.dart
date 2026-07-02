import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../Global/services/course_service.dart';

class OwnerCoursesController extends GetxController {
  final _service = CourseService();

  final courses    = <NurseryCourse>[].obs;
  final isLoading  = true.obs;
  final filterCat  = Rxn<CourseCategory>();
  final branchNames = <String, String>{}.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _loadBranchNames();
    _sub = _service.watchAllCourses().listen((list) {
      courses.value = list;
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> _loadBranchNames() async {
    await Get.find<BranchParentService>().getAll(
      callBack: (list) {
        branchNames.value = {
          for (final b in list.whereType<BranchModel>())
            (b.key ?? ''): b.name,
        };
      },
    );
  }

  String branchScopeLabel(NurseryCourse c) {
    if (c.isAllBranches) return 'كل الفروع';
    final names = c.branchIds
        .map((id) => branchNames[id] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return 'كل الفروع';
    return names.join('، ');
  }

  List<NurseryCourse> get filtered {
    if (filterCat.value == null) return courses;
    return courses.where((c) => c.category == filterCat.value).toList();
  }

  void filterBy(CourseCategory? cat) => filterCat.value = cat;

  // ─── Toggle active ────────────────────────────────────────────────────────
  Future<void> toggleActive(NurseryCourse course) async {
    await _service.toggleActive(course.id, course.isActive);
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<void> deleteCourse(NurseryCourse course) async {
    EasyLoading.show();
    final ok = await _service.deleteCourse(course);
    EasyLoading.dismiss();
    if (!ok) EasyLoading.showError('حدث خطأ');
  }

  // ─── Create ───────────────────────────────────────────────────────────────
  Future<bool> createCourse({
    required String title,
    required String description,
    required double price,
    required CourseCategory category,
    required String ageGroup,
    bool isActive = true,
    List<String> branchIds = const [],
    XFile? coverImage,
  }) async {
    EasyLoading.show(status: 'جاري الحفظ...');
    final ok = await _service.createCourse(
      title: title,
      description: description,
      price: price,
      category: category,
      ageGroup: ageGroup,
      isActive: isActive,
      branchIds: branchIds,
      coverImage: coverImage,
    );
    EasyLoading.dismiss();
    if (ok) {
      EasyLoading.showSuccess('تم إضافة الكورس');
    } else {
      EasyLoading.showError('حدث خطأ');
    }
    return ok;
  }

  // ─── Update ───────────────────────────────────────────────────────────────
  Future<bool> updateCourse({
    required NurseryCourse course,
    required String title,
    required String description,
    required double price,
    required CourseCategory category,
    required String ageGroup,
    bool? isActive,
    List<String>? branchIds,
    XFile? newCoverImage,
    bool removeCover = false,
  }) async {
    EasyLoading.show(status: 'جاري الحفظ...');
    final ok = await _service.updateCourse(
      course: course,
      title: title,
      description: description,
      price: price,
      category: category,
      ageGroup: ageGroup,
      isActive: isActive,
      branchIds: branchIds,
      newCoverImage: newCoverImage,
      removeCover: removeCover,
    );
    EasyLoading.dismiss();
    if (ok) {
      EasyLoading.showSuccess('تم تحديث الكورس');
    } else {
      EasyLoading.showError('حدث خطأ');
    }
    return ok;
  }
}
