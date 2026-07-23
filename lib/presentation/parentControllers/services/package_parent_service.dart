import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class PackageParentService {
  final BaseService<PackageModel> _service =
      Get.find<BaseService<PackageModel>>(tag: 'packages');

  /// [limit] caps the server-side result so existence probes fetch one row
  /// instead of the whole list. Only safe when the caller does NOT filter the
  /// result further (e.g. by branch), since the trimmed row might not match.
  Future<void> getAll({
    required Function(List<PackageModel?>) callBack,
    int? limit,
  }) async {
    await _service.getData(
      data: limit == null ? const {} : FirebaseFilter.firstN(limit),
      voidCallBack: callBack,
    );
  }

  Future<void> add({
    required PackageModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: (status) async {
        if (status == ResponseStatus.success) await _syncPriceRange();
        callBack(status);
      },
    );
  }

  Future<void> update({
    required PackageModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: (status) async {
        if (status == ResponseStatus.success) await _syncPriceRange();
        callBack(status);
      },
    );
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(
      id: id,
      voidCallBack: (status) async {
        if (status == ResponseStatus.success) await _syncPriceRange();
        callBack(status);
      },
    );
  }

  /// Recomputes the nursery's normalized monthly price range from all ACTIVE
  /// packages (across every branch) and mirrors it onto the discovery registry
  /// at `platform/info/{nurseryId}`. Same denormalization pattern as
  /// `childrenCount`. Based on ORIGINAL prices, so the range stays stable when
  /// a package's promotion expires.
  Future<void> _syncPriceRange() async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    List<PackageModel> all = const [];
    await getAll(
      callBack: (list) => all = list.whereType<PackageModel>().toList(),
    );
    final active = all.where((p) => p.isActive).toList();
    final ref = FirebaseDatabase.instance.ref('platform/info/$nurseryId');

    if (active.isEmpty) {
      await ref.update({'priceFrom': null, 'priceTo': null});
      return;
    }
    final normalized = active.map((p) => p.normalizedMonthlyPrice).toList()
      ..sort();
    await ref.update({
      'priceFrom': normalized.first,
      'priceTo': normalized.last,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
