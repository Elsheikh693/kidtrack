import '../../../index/index_main.dart';

/// CRUD over assessment runs (branch-scoped executions of a template).
/// Reads are automatically branch-filtered by BaseService for branch-bound
/// staff. Snapshotting a template into a run and materialising child rows live
/// in higher-level workflow code (later phases) that composes this service.
class AssessmentRunParentService {
  final BaseService<AssessmentRunModel> _service =
      Get.find<BaseService<AssessmentRunModel>>(tag: 'assessmentRuns');

  Future<void> getAll({
    required Function(List<AssessmentRunModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required AssessmentRunModel item,
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
    required AssessmentRunModel item,
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
}
