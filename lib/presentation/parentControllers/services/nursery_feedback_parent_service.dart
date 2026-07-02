import '../../../index/index_main.dart';

class NurseryFeedbackParentService {
  final BaseService<NurseryFeedbackModel> _service =
      Get.find<BaseService<NurseryFeedbackModel>>(tag: 'nurseryFeedback');

  /// Keyed by parentId so a family rates the nursery once (re-submit overwrites).
  Future<void> add({
    required NurseryFeedbackModel item,
    required Function(ResponseStatus) callBack,
    bool silent = false,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.parentId,
      voidCallBack: callBack,
      silent: silent,
    );
  }

  Future<void> getAll({
    required Function(List<NurseryFeedbackModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Cross-device backstop for the first-open gate: true if this parent already
  /// submitted feedback (their record exists under `feedback/{parentId}`).
  Future<bool> hasSubmitted(String parentId) async {
    if (parentId.isEmpty) return false;
    var exists = false;
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        exists = list.any((f) => f?.parentId == parentId);
      },
    );
    return exists;
  }
}
