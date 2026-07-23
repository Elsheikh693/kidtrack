import '../../../../index/index_main.dart';

class ChildStatesController extends GetxController {
  late final ChildStateTemplateParentService _service;
  final _session = SessionService();

  final RxList<ChildStateTemplateModel> items =
      <ChildStateTemplateModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ChildStateTemplateParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ChildStateTemplateModel>().toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      },
    );
    if (items.isEmpty) {
      await _seedDefaults();
    }
    isLoading.value = false;
  }

  /// First-run seeding: when the nursery has no states yet, create the ready-made
  /// ones (الأكل with its evaluation tree, النوم, الحمام). The owner can edit or
  /// delete them afterwards.
  Future<void> _seedDefaults() async {
    final nurseryId = _session.nurseryId ?? '';
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < ChildStateDefaults.seed.length; i++) {
      final d = ChildStateDefaults.seed[i];
      final model = ChildStateTemplateModel(
        key: d.key,
        nurseryId: nurseryId,
        title: d.titleKey.tr,
        icon: d.icon,
        createdAt: now + i,
        kind: d.kind,
        options: d.options
            .map((o) => ChildStateOption(
                  label: o.labelKey.tr,
                  subOptions: o.subLabelKeys.map((k) => k.tr).toList(),
                ))
            .toList(),
      );
      await _service.add(item: model, callBack: (_) {}, silent: true);
    }
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ChildStateTemplateModel>().toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      },
    );
  }

  void openAdd() => _openEditor(null);
  void openEdit(ChildStateTemplateModel item) => _openEditor(item);

  void _openEditor(ChildStateTemplateModel? item) {
    Get.to(
      () => ChildStateEditView(existing: item),
      transition: Transition.cupertino,
    )?.then((_) => loadData());
  }

  Future<void> delete(ChildStateTemplateModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('child_state_deleted'.tr);
          loadData();
        } else {
          Loader.showError('child_state_error'.tr);
        }
      },
    );
  }

  Future<void> toggle(ChildStateTemplateModel item) async {
    final updated = item.copyWith(isActive: !item.isActive);
    await _service.update(
      item: updated,
      callBack: (status) {
        if (status == ResponseStatus.success) loadData();
      },
    );
  }
}
