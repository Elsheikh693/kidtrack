import 'dart:async';
import '../../../../index/index_main.dart';
import '../../../../Global/services/event_service.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';

class ParentEventsController extends GetxController {
  final _service = EventService();
  late final SessionService _session;

  final upcomingEvents = <NurseryEventModel>[].obs;
  final isLoading = true.obs;

  final attendingMap = <String, bool>{}.obs;

  String get _parentId => _session.userId ?? '';
  String get _parentName => _session.currentUser?.displayName ?? 'ولي الأمر';
  String _activeChildId = '';
  String _activeChildName = '';

  StreamSubscription<List<NurseryEventModel>>? _eventsSub;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
    _resolveActiveChild();
    _subscribeEvents();
    // Re-resolve the child and refresh attendance when the parent switches.
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) {
        _resolveActiveChild();
        _refreshAttendance();
      },
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    _eventsSub?.cancel();
    super.onClose();
  }

  void _resolveActiveChild() {
    final svc = Get.find<ActiveChildService>();
    _activeChildId = svc.childId.value;
    _activeChildName = svc.childName.value;
  }

  void _subscribeEvents() {
    _eventsSub?.cancel();
    _eventsSub = _service.watchUpcomingEvents().listen((list) async {
      upcomingEvents.assignAll(list);
      isLoading.value = false;
      await _refreshAttendance();
    });
  }

  Future<void> _refreshAttendance() async {
    if (_activeChildId.isEmpty) return;
    final map = <String, bool>{};
    for (final e in upcomingEvents) {
      map[e.id] = await _service.isAttending(e.id, _activeChildId);
    }
    attendingMap.assignAll(map);
  }

  bool isAttending(String eventId) => attendingMap[eventId] ?? false;

  Future<void> toggleAttendance(NurseryEventModel event) async {
    if (_activeChildId.isEmpty) {
      Loader.showError('event_error_no_child'.tr);
      return;
    }
    final currently = isAttending(event.id);
    Loader.show();
    bool ok;
    if (currently) {
      ok = await _service.cancelAttendance(eventId: event.id, childId: _activeChildId);
    } else {
      ok = await _service.confirmAttendance(
        eventId: event.id,
        childId: _activeChildId,
        parentId: _parentId,
        childName: _activeChildName,
        parentName: _parentName,
      );
    }
    Loader.dismiss();
    if (ok) {
      attendingMap[event.id] = !currently;
      attendingMap.refresh();
      Loader.showSuccess(currently ? 'event_cancelled_attendance'.tr : 'event_confirmed_attendance'.tr);
    } else {
      Loader.showError('common_error'.tr);
    }
  }

  NurseryEventModel? get nextEvent =>
      upcomingEvents.isNotEmpty ? upcomingEvents.first : null;
}
