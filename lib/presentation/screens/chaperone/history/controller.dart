import '../../../../index/index_main.dart';

class ChaperoneHistoryController extends GetxController {
  final _session = SessionService();
  late final BusTrackingService _service;

  final selectedDate = DateTime.now().obs;
  final sessions = <BusSession>[].obs;
  final isLoading = false.obs;

  String get branchId => _session.branchId ?? '';
  String get chaperoneId => _session.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    _service = BusTrackingService();
    load();
  }

  Future<void> pickDate(DateTime date) async {
    selectedDate.value = date;
    await load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final d = selectedDate.value;
    final dayStart = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    final dayEnd =
        DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    sessions.value = await _service.getHistory(
      branchId: branchId,
      chaperoneId: chaperoneId,
      dayStartMs: dayStart,
      dayEndMs: dayEnd,
    );
    isLoading.value = false;
  }
}
