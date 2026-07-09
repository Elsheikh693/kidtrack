import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class ProgramParentService {
  final BaseService<ProgramModel> _service =
      Get.find<BaseService<ProgramModel>>(tag: 'programs');

  /// [limit] caps the server-side result so existence probes fetch one row
  /// instead of the whole list.
  Future<void> getAll({
    required Function(List<ProgramModel?>) callBack,
    int? limit,
  }) async {
    await _service.getData(
      data: limit == null ? const {} : FirebaseFilter.firstN(limit),
      voidCallBack: callBack,
    );
  }

  Future<void> add({
    required ProgramModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
    await _syncInfoCache();
  }

  Future<void> update({
    required ProgramModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
    await _syncInfoCache();
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
    await _syncInfoCache();
  }

  /// Mirrors the canonical program names into `platform/info/{id}/programs`, the
  /// denormalized cache Discovery reads pre-login. Called after every mutation
  /// so the public profile and the manager's own editor never drift — no matter
  /// which screen the change came from.
  Future<void> _syncInfoCache() async {
    final id = ApiConstants.nurseryId;
    if (id.isEmpty) return;
    final names = <String>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        for (final p in list) {
          if (p == null || !p.isActive) continue;
          final name = p.name.trim();
          if (name.isNotEmpty && !names.contains(name)) names.add(name);
        }
      },
    );
    await FirebaseDatabase.instance.ref('platform/info/$id/programs').set(names);
  }
}
