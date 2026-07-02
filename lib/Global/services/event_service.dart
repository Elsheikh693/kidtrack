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
      );
      await _eventsRef.child(event.id).update(updated.toJson());
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
