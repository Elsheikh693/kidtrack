import '../../../../index/index_main.dart';

/// Lists the nursery's events for staff so a teacher / bus chaperone can open an
/// event and add photos to it. Scoped to the viewer's branch. Newest first.
class StaffEventsController extends GetxController {
  late final EventService _service;
  late final SessionService _session;

  final events = <NurseryEventModel>[].obs;
  final isLoading = true.obs;

  StreamSubscription<List<NurseryEventModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = EventService();
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _service.watchAllEvents().listen((list) {
      final scoped = list
          .where((e) => _session.seesBranch(e.branchId))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      events.assignAll(scoped);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
