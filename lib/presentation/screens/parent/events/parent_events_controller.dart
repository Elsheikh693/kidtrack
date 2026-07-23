import 'dart:async';
import '../../../../index/index_main.dart';
import '../../../../Global/services/event_service.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';

class ParentEventsController extends GetxController {
  final _service = EventService();
  late final SessionService _session;

  final upcomingEvents = <NurseryEventModel>[].obs;

  /// Events (any date) that carry approved photos for the active child — the
  /// parent's fun-day photo albums. Newest first.
  final photoAlbums = <NurseryEventModel>[].obs;
  final isLoading = true.obs;

  final attendingMap = <String, bool>{}.obs;

  List<NurseryEventModel> _allEvents = const [];

  String get _parentId => _session.userId ?? '';
  String get _parentName => _session.currentUser?.displayName ?? 'parenteduc24_default_parent'.tr;
  String _activeChildId = '';
  String _activeChildName = '';
  String _activeChildBranchId = '';

  String get activeChildId => _activeChildId;

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
        _recompute();
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
    _activeChildBranchId = svc.branchId.value;
  }

  void _subscribeEvents() {
    _eventsSub?.cancel();
    // Watch the full events list so we can surface photo albums for past events
    // too (fun-day photos are usually approved on/after the event day). The
    // upcoming (RSVP) list is derived locally, preserving prior behavior.
    _eventsSub = _service.watchAllEvents().listen((list) async {
      _allEvents = list;
      _recompute();
      isLoading.value = false;
      await _refreshAttendance();
    });
  }

  void _recompute() {
    final now = DateTime.now();
    final startOfToday =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    // A parent only sees events for their active child's branch (plus
    // all-branch events whose branchId is empty). Parents have no session
    // branch, so scope by the CHILD's branch, mirroring how classroom-scoped
    // content is filtered on the guardian side.
    upcomingEvents.assignAll(
      _allEvents
          .where((e) =>
              e.isActive &&
              e.date >= startOfToday &&
              SessionService.branchVisible(_activeChildBranchId, e.branchId))
          .toList(),
    );
    final cid = _activeChildId;
    photoAlbums.assignAll(
      cid.isEmpty
          ? const <NurseryEventModel>[]
          : (_allEvents
              .where((e) => e.approvedUrlsForChild(cid).isNotEmpty)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date))),
    );
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
