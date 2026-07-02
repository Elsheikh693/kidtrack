import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../Global/services/course_service.dart';

class CourseLessonsController extends GetxController {
  CourseLessonsController(this.course);

  final NurseryCourse course;
  final _service = CourseService();

  final lessons   = <CourseLesson>[].obs;
  final isLoading = true.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _service.watchLessons(course.id).listen((list) {
      lessons.value = list;
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<bool> createLesson({
    required String title,
    required String? description,
    required int durationMinutes,
    required LessonContentType contentType,
    required String? contentUrl,
    required String? textContent,
  }) async {
    EasyLoading.show(status: 'جاري الحفظ...');
    final ok = await _service.createLesson(
      courseId: course.id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      contentType: contentType,
      contentUrl: contentUrl,
      textContent: textContent,
      orderIndex: lessons.length,
    );
    EasyLoading.dismiss();
    if (ok) {
      EasyLoading.showSuccess('تم إضافة الدرس');
    } else {
      EasyLoading.showError('حدث خطأ');
    }
    return ok;
  }

  Future<bool> updateLesson({
    required CourseLesson lesson,
    required String title,
    required String? description,
    required int durationMinutes,
    required LessonContentType contentType,
    required String? contentUrl,
    required String? textContent,
  }) async {
    EasyLoading.show(status: 'جاري الحفظ...');
    final ok = await _service.updateLesson(
      courseId: course.id,
      lesson: lesson,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      contentType: contentType,
      contentUrl: contentUrl,
      textContent: textContent,
    );
    EasyLoading.dismiss();
    if (ok) {
      EasyLoading.showSuccess('تم تحديث الدرس');
    } else {
      EasyLoading.showError('حدث خطأ');
    }
    return ok;
  }

  Future<void> deleteLesson(CourseLesson lesson) async {
    EasyLoading.show();
    await _service.deleteLesson(course.id, lesson.id);
    EasyLoading.dismiss();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...lessons];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    lessons.value = list;
    await _service.reorderLessons(course.id, list);
  }
}
