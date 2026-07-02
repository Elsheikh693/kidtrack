import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class ClassroomParentService {
  final BaseService<ClassroomModel> _service =
      Get.find<BaseService<ClassroomModel>>(tag: 'classrooms');

  Future<void> getAll({required Function(List<ClassroomModel?>) callBack}) async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) {
      callBack([]);
      return;
    }
    try {
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/classrooms')
          .get();
      if (!snap.exists || snap.value == null) {
        callBack([]);
        return;
      }
      final raw = snap.value as Map? ?? {};
      final list = raw.entries
          .where((e) => e.value is Map)
          .map((e) {
            try {
              final json = Map<String, dynamic>.from(
                (e.value as Map).map((k, v) => MapEntry(k.toString(), v)),
              );
              json['key'] = e.key.toString();
              return ClassroomModel.fromJson(json);
            } catch (_) {
              return null;
            }
          })
          .whereType<ClassroomModel>()
          .toList();
      callBack(list);
    } catch (_) {
      await _service.getData(data: {}, voidCallBack: callBack);
    }
  }

  Future<void> add({
    required ClassroomModel item,
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
    required ClassroomModel item,
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
