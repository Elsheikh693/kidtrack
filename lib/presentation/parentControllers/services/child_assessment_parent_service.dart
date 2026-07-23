import '../../../index/index_main.dart';

/// CRUD over per-child assessment records (branch-scoped). The record key is
/// `{runId}_{childId}` (set by the caller on `item.key`) so materialising a run
/// is idempotent — re-running never duplicates a child's row. Grading, review,
/// publish, lock and retake mutations flow through [update] with a freshly
/// computed model (higher-level workflow code composes those in later phases).
class ChildAssessmentParentService {
  final BaseService<ChildAssessmentModel> _service =
      Get.find<BaseService<ChildAssessmentModel>>(tag: 'childAssessments');

  Future<void> getAll({
    required Function(List<ChildAssessmentModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ChildAssessmentModel item,
    required Function(ResponseStatus) callBack,
    bool silent = false,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
      silent: silent,
    );
  }

  Future<void> update({
    required ChildAssessmentModel item,
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
