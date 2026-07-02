import '../../../index/index_main.dart';

/// Read-side wrapper used by parents to fetch the nursery's direct-contact
/// numbers (reception, manager, …) for the WhatsApp sheet.
class NurseryContactParentService {
  final BaseService<NurseryContactModel> _service =
      Get.find<BaseService<NurseryContactModel>>(tag: 'nurseryContacts');

  Future<void> getAll({
    required Function(List<NurseryContactModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }
}
