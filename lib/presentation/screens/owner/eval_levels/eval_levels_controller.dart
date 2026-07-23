import '../../../../index/index_main.dart';

class EvalLevelsController extends GetxController {
  late final EvalLevelTemplateParentService _service;
  final _session = SessionService();

  final RxList<EvalLevelTemplateModel> items = <EvalLevelTemplateModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<EvalLevelTemplateParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<EvalLevelTemplateModel>().toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      },
    );
    if (items.isEmpty) {
      await _seedDefaults();
    }
    isLoading.value = false;
    await _refreshRegistry();
  }

  /// First-run seeding of the three built-in levels (keys kept as the legacy
  /// stored strings so old activity evaluations still resolve).
  Future<void> _seedDefaults() async {
    final nurseryId = _session.nurseryId ?? '';
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < EvalLevelDefaults.seed.length; i++) {
      final d = EvalLevelDefaults.seed[i];
      final model = EvalLevelTemplateModel(
        key: d.key,
        nurseryId: nurseryId,
        title: d.titleKey.tr,
        icon: d.icon,
        color: d.color,
        score: d.score,
        createdAt: now + i,
      );
      await _service.add(item: model, callBack: (_) {}, silent: true);
    }
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<EvalLevelTemplateModel>().toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      },
    );
  }

  void openAdd() => _openEditor(null);
  void openEdit(EvalLevelTemplateModel item) => _openEditor(item);

  void _openEditor(EvalLevelTemplateModel? item) {
    Get.to(
      () => EvalLevelEditView(existing: item),
      transition: Transition.cupertino,
    )?.then((_) => loadData());
  }

  Future<void> delete(EvalLevelTemplateModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('eval_level_deleted'.tr);
          loadData();
        } else {
          Loader.showError('eval_level_error'.tr);
        }
      },
    );
  }

  Future<void> toggle(EvalLevelTemplateModel item) async {
    final updated = item.copyWith(isActive: !item.isActive);
    await _service.update(
      item: updated,
      callBack: (status) {
        if (status == ResponseStatus.success) loadData();
      },
    );
  }

  Future<void> _refreshRegistry() async {
    if (Get.isRegistered<EvalLevelsRegistry>()) {
      await Get.find<EvalLevelsRegistry>().load();
    }
  }
}
