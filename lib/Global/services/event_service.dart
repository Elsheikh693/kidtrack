import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../Data/models/nursery_event/nursery_event_model.dart';
import '../../Data/models/event_attendance/event_attendance_model.dart';
import '../../Data/models/classroom_activity/activity_photo_model.dart';
import 'session_service.dart';

class EventService {
  final _db = FirebaseDatabase.instance;
  final _storage = FirebaseStorage.instance;
  final _session = SessionService();

  String get _nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _eventsRef => _db.ref('platform/$_nurseryId/events');

  DatabaseReference _attendeesRef(String eventId) =>
      _db.ref('platform/$_nurseryId/eventAttendees/$eventId');

  // ─── Watch all events (receptionist) ──────────────────────────────────────
  Stream<List<NurseryEventModel>> watchAllEvents() {
    return _eventsRef.orderByChild('date').onValue.map((event) {
      return _parseEvents(event.snapshot.value);
    });
  }

  // ─── Watch upcoming events only (parent) ──────────────────────────────────
  Stream<List<NurseryEventModel>> watchUpcomingEvents() {
    // Start from the beginning of today (midnight) — events are stored with
    // their date at midnight, so using DateTime.now() would hide events that
    // happen later today (their stored date is < the current time).
    final now = DateTime.now();
    final startOfToday =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    return _eventsRef
        .orderByChild('date')
        .startAt(startOfToday)
        .onValue
        .map((event) {
      final list = _parseEvents(event.snapshot.value);
      return list.where((e) => e.isActive).toList();
    });
  }

  List<NurseryEventModel> _parseEvents(dynamic data) {
    if (data == null || data is! Map) return [];
    final events = <NurseryEventModel>[];
    for (final entry in data.entries) {
      try {
        final map = Map<String, dynamic>.from(entry.value as Map);
        events.add(NurseryEventModel.fromJson(map, id: entry.key.toString()));
      } catch (_) {}
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  // ─── Create event (receptionist) ──────────────────────────────────────────
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    String? timeStr,
    String? location,
    required EventCategory category,
    double? price,
    XFile? coverImage,
  }) async {
    try {
      final id = const Uuid().v4();
      String? imageUrl;
      if (coverImage != null) imageUrl = await _uploadCover(id, coverImage);
      final event = NurseryEventModel(
        id: id,
        nurseryId: _nurseryId,
        branchId: _session.branchId,
        title: title,
        description: description,
        date: date.millisecondsSinceEpoch,
        timeStr: timeStr,
        location: location,
        coverImage: imageUrl,
        category: category,
        price: price,
        createdBy: _session.userId ?? '',
        createdByName: _session.currentUser?.displayName ?? 'الاستقبال',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _eventsRef.child(id).set(event.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Update event (receptionist) ──────────────────────────────────────────
  Future<bool> updateEvent({
    required NurseryEventModel event,
    required String title,
    required String description,
    required DateTime date,
    String? timeStr,
    String? location,
    required EventCategory category,
    double? price,
    XFile? newCoverImage,
    bool removeCover = false,
  }) async {
    try {
      String? imageUrl = event.coverImage;
      if (removeCover && imageUrl != null) {
        await _deleteCoverByUrl(imageUrl);
        imageUrl = null;
      } else if (newCoverImage != null) {
        if (imageUrl != null) await _deleteCoverByUrl(imageUrl);
        imageUrl = await _uploadCover(event.id, newCoverImage);
      }
      final updated = event.copyWith(
        title: title,
        description: description,
        date: date.millisecondsSinceEpoch,
        timeStr: timeStr,
        location: location,
        coverImage: imageUrl,
        category: category,
        price: price,
      );
      final data = updated.toJson();
      // Write price explicitly (even when null) so editing a paid event back to
      // free actually clears the stored amount — toJson omits null keys.
      data['price'] = price;
      await _eventsRef.child(event.id).update(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Delete event (receptionist) ──────────────────────────────────────────
  Future<bool> deleteEvent(NurseryEventModel event) async {
    try {
      if (event.coverImage != null) await _deleteCoverByUrl(event.coverImage!);
      await _eventsRef.child(event.id).remove();
      await _attendeesRef(event.id).remove();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Watch attendees for an event (receptionist) ──────────────────────────
  Stream<List<EventAttendanceModel>> watchAttendees(String eventId) {
    return _attendeesRef(eventId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <EventAttendanceModel>[];
      final list = <EventAttendanceModel>[];
      for (final entry in data.entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(EventAttendanceModel.fromJson(
            map,
            eventId: eventId,
            childId: entry.key.toString(),
          ));
        } catch (_) {}
      }
      list.sort((a, b) => a.confirmedAt.compareTo(b.confirmedAt));
      return list;
    });
  }

  // ─── Confirm attendance (parent) ──────────────────────────────────────────
  Future<bool> confirmAttendance({
    required String eventId,
    required String childId,
    required String parentId,
    required String childName,
    required String parentName,
  }) async {
    try {
      final entry = EventAttendanceModel(
        eventId: eventId,
        childId: childId,
        parentId: parentId,
        childName: childName,
        parentName: parentName,
        confirmedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _attendeesRef(eventId).child(childId).set(entry.toJson());
      // increment counter
      await _eventsRef.child(eventId).child('attendeesCount').set(
        ServerValue.increment(1),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Cancel attendance (parent) ───────────────────────────────────────────
  Future<bool> cancelAttendance({
    required String eventId,
    required String childId,
  }) async {
    try {
      await _attendeesRef(eventId).child(childId).remove();
      await _eventsRef.child(eventId).child('attendeesCount').set(
        ServerValue.increment(-1),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Check if child is attending (parent) ─────────────────────────────────
  Future<bool> isAttending(String eventId, String childId) async {
    final snap = await _attendeesRef(eventId).child(childId).get();
    return snap.exists;
  }

  // ─── Watch single child attendance status (parent) ────────────────────────
  Stream<bool> watchAttending(String eventId, String childId) {
    return _attendeesRef(eventId).child(childId).onValue.map(
      (e) => e.snapshot.exists,
    );
  }

  // ─── Event photos ─────────────────────────────────────────────────────────
  // Any staff member may upload a photo to an event. Photos are stored as
  // `isApproved = false` (hidden from guardians) until a reviewer approves the
  // batch. Reuses the generic ActivityPhoto model + audience targeting.

  DatabaseReference _photosRef(String eventId) =>
      _eventsRef.child('$eventId/photos');

  /// Reads the nursery-wide photo-approval policy
  /// (`platform/info/{nurseryId}/photosNeedApproval`). A missing value or any
  /// read error defaults to `true` (review required) to preserve the flow.
  Future<bool> _photosNeedApproval() async {
    final id = _nurseryId;
    if (id.isEmpty) return true;
    try {
      final snap = await _db.ref('platform/info/$id/photosNeedApproval').get();
      final v = snap.value;
      return !(v == false || v == 0 || v == '0' || v == 'false');
    } catch (_) {
      return true;
    }
  }

  /// Uploads one photo to an event. When the nursery requires review the photo
  /// stays `isApproved = false` until a reviewer approves it; when review is
  /// turned off it is published immediately (`isApproved = true`) so guardians
  /// see it in the event's photos. Returns the created [ActivityPhoto] so the
  /// caller can update local state optimistically.
  Future<ActivityPhoto?> uploadEventPhoto({
    required String eventId,
    required File file,
    String? uploadedBy,
  }) async {
    final photoId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final autoApprove = !await _photosNeedApproval();
      final ref = _storage.ref(
        'platform/$_nurseryId/event_photos/$eventId/$photoId.jpg',
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      final now = DateTime.now().millisecondsSinceEpoch;
      final photo = ActivityPhoto(
        id: photoId,
        url: url,
        isApproved: autoApprove,
        approvedBy: autoApprove ? (uploadedBy ?? 'auto') : null,
        approvedAt: autoApprove ? now : null,
        uploadedBy: uploadedBy,
        uploadedAt: now,
      );
      await _photosRef(eventId).child(photoId).set(photo.toJson());
      return photo;
    } catch (_) {
      return null;
    }
  }

  /// Removes a photo from the event node + its Storage object.
  Future<void> deleteEventPhoto({
    required String eventId,
    required String photoId,
  }) async {
    try {
      await _photosRef(eventId).child(photoId).remove();
    } catch (_) {}
    try {
      await _storage
          .ref('platform/$_nurseryId/event_photos/$eventId/$photoId.jpg')
          .delete();
    } catch (_) {}
  }

  /// Approves the given pending photos in one batch — they flip to
  /// `isApproved = true` and become visible to guardians together. Clears the
  /// review-notification debounce flag so a later batch notifies again.
  Future<void> approveEventPhotos({
    required String eventId,
    required List<String> photoIds,
    required String approvedBy,
    int bannerDays = 0,
  }) async {
    if (photoIds.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = <String, dynamic>{
      'reviewNotifiedAt': null,
      // Publish window for the parents' home photo carousel — counted from now.
      'photosBannerDays': bannerDays,
      'photosPublishedAt': now,
    };
    for (final id in photoIds) {
      updates['photos/$id/isApproved'] = true;
      updates['photos/$id/approvedBy'] = approvedBy;
      updates['photos/$id/approvedAt'] = now;
    }
    try {
      await _eventsRef.child(eventId).update(updates);
    } catch (_) {}
  }

  /// Sets a single photo's audience (everyone or a set of children). Clears
  /// `targetChildren` when switching back to everyone.
  Future<void> updateEventPhotoAudience({
    required String eventId,
    required String photoId,
    required AudienceType audienceType,
    List<String> targetChildren = const [],
  }) async {
    try {
      await _photosRef(eventId).child(photoId).update({
        'audienceType': audienceType.key,
        'targetChildren':
            audienceType == AudienceType.children ? targetChildren : null,
      });
    } catch (_) {}
  }

  /// Real-time stream of events that still have photos awaiting review. Used by
  /// the media-approval screen (reviewer filters by branch).
  Stream<List<NurseryEventModel>> watchPendingEvents() {
    return _eventsRef.onValue.map((event) {
      final list = _parseEvents(event.snapshot.value);
      return list.where((e) => e.hasPendingPhotos).toList();
    });
  }

  /// Links the event to the social-feed gallery post created for its photos so
  /// a later re-approval updates that post instead of creating a duplicate.
  Future<void> setPhotosPostId(String eventId, String postId) async {
    try {
      await _eventsRef.child(eventId).child('photosPostId').set(postId);
    } catch (_) {}
  }

  /// Real-time stream of a single event (so the staff photos screen live-updates
  /// as uploads land and reviewers approve/reject).
  Stream<NurseryEventModel?> watchEvent(String eventId) {
    return _eventsRef.child(eventId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return null;
      try {
        final map = Map<String, dynamic>.from(data);
        return NurseryEventModel.fromJson(map, id: eventId);
      } catch (_) {
        return null;
      }
    });
  }

  // ─── Image helpers ────────────────────────────────────────────────────────
  Future<String?> _uploadCover(String eventId, XFile xfile) async {
    try {
      final compressed = await _compress(xfile.path);
      final file = compressed ?? File(xfile.path);
      final ref = _storage.ref('nurseries/$_nurseryId/events/$eventId/cover.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<File?> _compress(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_ev.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        path, target, quality: 75, minWidth: 1080, minHeight: 720,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteCoverByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}
