import '../../../index/index_main.dart';

/// CRUD access to class-level written exams. Reads pull the whole node and
/// filter client-side (MVP — same approach as [GuardianNoteParentService]);
/// branch scoping is applied centrally in [BaseService.getData] since
/// [ExamModel] is `BranchScoped`.
class ExamParentService {
  final BaseService<ExamModel> _service =
      Get.find<BaseService<ExamModel>>(tag: 'exams');

  Future<void> getAll({
    required Function(List<ExamModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ExamModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required ExamModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }

  /// Every exam set for one classroom, newest first (staff exams list).
  Future<List<ExamModel>> getForClassroom(String classroomId) async {
    final out = <ExamModel>[];
    await getAll(
      callBack: (list) => out.addAll(
        list
            .whereType<ExamModel>()
            .where((e) => e.classroomId == classroomId),
      ),
    );
    out.sort((a, b) => b.examDate.compareTo(a.examDate));
    return out;
  }
}
