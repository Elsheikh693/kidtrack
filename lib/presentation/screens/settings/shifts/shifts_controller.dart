import '../../../../index/index_main.dart';

class ShiftsController extends GetxController {
  late final ShiftParentService _service;
  final _session = SessionService();

  final RxList<ShiftModel> items = <ShiftModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ShiftParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ShiftModel>().toList()
          ..sort((a, b) {
            final s = a.sortOrder.compareTo(b.sortOrder);
            return s != 0 ? s : a.startMinutes.compareTo(b.startMinutes);
          });
      },
    );
    if (items.isEmpty) {
      await _seedDefaults();
    }
    isLoading.value = false;
  }

  /// First-run seeding: create the three legacy shifts with their original keys
  /// so existing `child.shift` values ('morning'/'between'/'evening') resolve.
  Future<void> _seedDefaults() async {
    final nurseryId = _session.nurseryId ?? '';
    for (var i = 0; i < ShiftDefaults.seed.length; i++) {
      final d = ShiftDefaults.seed[i];
      final model = ShiftModel(
        key: d.key,
        nurseryId: nurseryId,
        name: d.nameKey.tr,
        startMinutes: d.start,
        endMinutes: d.end,
        sortOrder: i,
      );
      await _service.add(item: model, callBack: (_) {}, silent: true);
    }
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ShiftModel>().toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      },
    );
  }

  void openAdd() => _openSheet(null);
  void openEdit(ShiftModel item) => _openSheet(item);

  void _openSheet(ShiftModel? item) {
    Get.bottomSheet(
      ShiftSheet(existing: item, nextSortOrder: items.length),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ShiftModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('shifts_deleted'.tr);
          loadData();
        } else {
          Loader.showError('shifts_error'.tr);
        }
      },
    );
  }
}
