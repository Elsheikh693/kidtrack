import 'dart:io';

import '../../../../index/index_main.dart';

/// Drives the shared staff "event photos" screen. Any staff member (teacher,
/// bus chaperone, reception, manager) may upload photos to an event; uploads
/// land as `isApproved = false` (hidden from guardians) until a reviewer
/// approves them. Staff see every photo — approved and pending alike.
class EventPhotosController extends GetxController {
  late final EventService _service;
  late final SessionService _session;

  final event = Rxn<NurseryEventModel>();
  final isUploading = false.obs;

  StreamSubscription<NurseryEventModel?>? _sub;

  String get _uid => _session.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    _session = Get.find<SessionService>();
    _service = EventService();
    final arg = Get.arguments;
    if (arg is NurseryEventModel) {
      event.value = arg;
      _watch(arg.id);
    }
  }

  void _watch(String eventId) {
    _sub?.cancel();
    _sub = _service.watchEvent(eventId).listen((e) {
      if (e != null) event.value = e;
    });
  }

  /// Newest-first photos for the grid.
  List<ActivityPhoto> get photos {
    final e = event.value;
    if (e == null) return const [];
    return e.photos.values.toList()
      ..sort((a, b) => (b.uploadedAt ?? 0).compareTo(a.uploadedAt ?? 0));
  }

  Future<void> uploadPhotos() async {
    final e = event.value;
    if (e == null) return;
    final source = await showImageSourceSheet();
    if (source == null) return;

    Future<void> upload(List<File> files) async {
      if (files.isEmpty) return;
      isUploading.value = true;
      var failed = 0;
      for (final file in files) {
        final photo = await _service.uploadEventPhoto(
          eventId: e.id,
          file: file,
          uploadedBy: _uid,
        );
        if (photo == null) failed++;
      }
      isUploading.value = false;
      if (failed > 0) {
        Loader.showError('event_photos_upload_error'.tr);
      } else {
        Loader.showSuccess('event_photos_upload_success'.tr);
      }
    }

    final picker = PickedImage();
    if (source == ImageSource.camera) {
      await picker.capturePhoto(
        callBack: (file) async => file == null ? null : upload([file]),
      );
    } else {
      await picker.pickMultiImages(callBack: upload);
    }
  }

  /// Remove a still-pending photo (approved photos are managed by the reviewer).
  Future<void> removePhoto(String photoId) async {
    final e = event.value;
    if (e == null) return;
    Loader.show();
    try {
      await _service.deleteEventPhoto(eventId: e.id, photoId: photoId);
      Loader.dismiss();
    } catch (_) {
      Loader.showError('event_photos_delete_error'.tr);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
