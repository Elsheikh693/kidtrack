import '../../../../index/index_main.dart';

class EvaluationReasonsController extends GetxController {
  late final EvaluationReasonsService _service;
  late final SessionService _session;

  final reasons = <EvaluationReasonModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  String get nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<EvaluationReasonsService>();
    _session = Get.find<SessionService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    reasons.value = await _service.getAll(nurseryId);
    isLoading.value = false;
  }

  Future<void> refresh() => _load();

  Future<void> addReason(String title) async {
    if (title.trim().isEmpty) return;
    isSaving.value = true;
    await _service.addOrGet(nurseryId, title.trim());
    await _load();
    isSaving.value = false;
  }

  Future<void> updateTitle(EvaluationReasonModel reason, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    isSaving.value = true;
    await _service.updateReason(
        nurseryId, reason.copyWith(title: newTitle.trim()));
    await _load();
    isSaving.value = false;
  }

  Future<void> toggleActive(EvaluationReasonModel reason) async {
    await _service.updateReason(
        nurseryId, reason.copyWith(isActive: !reason.isActive));
    await _load();
  }

  Future<void> delete(EvaluationReasonModel reason) async {
    if (reason.key == null) return;
    await _service.deleteReason(nurseryId, reason.key!);
    reasons.removeWhere((r) => r.key == reason.key);
  }
}
