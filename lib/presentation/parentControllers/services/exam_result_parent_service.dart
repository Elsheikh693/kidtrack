import '../../../index/index_main.dart';

/// CRUD access to per-child written-exam results. Upsert == add (both PATCH the
/// deterministic key `er_{examId}_{childId}`, so re-grading rewrites in place).
/// Reads pull the whole node and filter client-side (MVP); [ExamResultModel] is
/// `BranchScoped` so branch scoping is applied centrally in
/// [BaseService.getData].
class ExamResultParentService {
  final BaseService<ExamResultModel> _service =
      Get.find<BaseService<ExamResultModel>>(tag: 'examResults');

  Future<void> getAll({
    required Function(List<ExamResultModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Upsert (add == update — both PATCH the deterministic key).
  Future<void> upsert({
    required ExamResultModel item,
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

  /// Every result under one exam (staff grading screen prefill).
  Future<List<ExamResultModel>> getForExam(String examId) async {
    final out = <ExamResultModel>[];
    await getAll(
      callBack: (list) => out.addAll(
        list.whereType<ExamResultModel>().where((r) => r.examId == examId),
      ),
    );
    return out;
  }

  /// Every graded result for one child, newest exam first (guardian exam list).
  Future<List<ExamResultModel>> getForChild(String childId) async {
    final out = <ExamResultModel>[];
    await getAll(
      callBack: (list) => out.addAll(
        list.whereType<ExamResultModel>().where(
              (r) => r.childId == childId && r.grade.isNotEmpty,
            ),
      ),
    );
    out.sort((a, b) => b.examDate.compareTo(a.examDate));
    return out;
  }
}
