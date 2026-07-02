import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../../../../index/index_main.dart';
import '../../../../Global/services/event_service.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../../../../Data/models/event_attendance/event_attendance_model.dart';

class ReceptionistEventsController extends GetxController {
  final _service = EventService();

  final events = <NurseryEventModel>[].obs;
  final isLoading = true.obs;
  final filterUpcoming = true.obs;

  StreamSubscription<List<NurseryEventModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _service.watchAllEvents().listen((list) {
      events.assignAll(list);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  List<NurseryEventModel> get filteredEvents {
    if (filterUpcoming.value) {
      return events.where((e) => e.isUpcoming).toList();
    }
    return events.toList();
  }

  void toggleFilter() => filterUpcoming.toggle();

  Future<void> deleteEvent(NurseryEventModel event) async {
    Loader.show();
    final ok = await _service.deleteEvent(event);
    Loader.dismiss();
    if (!ok) Loader.showError('event_error_delete'.tr);
  }

  // ─── Attendees sheet data ──────────────────────────────────────────────────
  final attendees = <EventAttendanceModel>[].obs;
  StreamSubscription<List<EventAttendanceModel>>? _attendeesSub;

  void watchAttendeesFor(String eventId) {
    _attendeesSub?.cancel();
    _attendeesSub = _service.watchAttendees(eventId).listen((list) {
      attendees.assignAll(list);
    });
  }

  void stopWatchingAttendees() {
    _attendeesSub?.cancel();
    attendees.clear();
  }
}

// ─── Create/Edit controller ───────────────────────────────────────────────────

class CreateEventController extends GetxController {
  final _service = EventService();

  final NurseryEventModel? editEvent;
  CreateEventController({this.editEvent});

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final timeCtrl = TextEditingController();

  final selectedDate = Rx<DateTime?>(null);
  final selectedCategory = EventCategory.fun.obs;
  final coverImage = Rx<XFile?>(null);
  final removeCover = false.obs;
  final isLoading = false.obs;

  /// Bumped whenever [timeCtrl] is set from the time picker so the
  /// (non-reactive) text controller's display can rebuild.
  final timeTick = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (editEvent != null) {
      titleCtrl.text = editEvent!.title;
      descCtrl.text = editEvent!.description;
      locationCtrl.text = editEvent!.location ?? '';
      timeCtrl.text = editEvent!.timeStr ?? '';
      selectedDate.value = editEvent!.dateTime;
      selectedCategory.value = editEvent!.category;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    timeCtrl.dispose();
    super.onClose();
  }

  Future<void> pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      coverImage.value = picked;
      removeCover.value = false;
    }
  }

  void clearCover() {
    coverImage.value = null;
    removeCover.value = true;
  }

  Future<bool> submit() async {
    if (titleCtrl.text.trim().isEmpty) {
      Loader.showError('event_error_title'.tr);
      return false;
    }
    if (selectedDate.value == null) {
      Loader.showError('event_error_date'.tr);
      return false;
    }
    isLoading.value = true;
    Loader.show();

    bool ok;
    if (editEvent == null) {
      ok = await _service.createEvent(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        date: selectedDate.value!,
        timeStr: timeCtrl.text.trim().isEmpty ? null : timeCtrl.text.trim(),
        location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
        category: selectedCategory.value,
        coverImage: coverImage.value,
      );
    } else {
      ok = await _service.updateEvent(
        event: editEvent!,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        date: selectedDate.value!,
        timeStr: timeCtrl.text.trim().isEmpty ? null : timeCtrl.text.trim(),
        location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
        category: selectedCategory.value,
        newCoverImage: coverImage.value,
        removeCover: removeCover.value,
      );
    }

    Loader.dismiss();
    isLoading.value = false;
    return ok;
  }
}
