import 'package:flutter/material.dart';
import '../classroom_activity/activity_photo_model.dart';

enum EventCategory {
  fun,
  trip,
  meeting,
  graduation,
  sports,
  cultural,
  other;

  String get labelKey => 'event_category_$name';

  IconData get icon {
    switch (this) {
      case EventCategory.fun:        return Icons.celebration_rounded;
      case EventCategory.trip:       return Icons.directions_bus_rounded;
      case EventCategory.meeting:    return Icons.groups_rounded;
      case EventCategory.graduation: return Icons.school_rounded;
      case EventCategory.sports:     return Icons.sports_soccer_rounded;
      case EventCategory.cultural:   return Icons.palette_rounded;
      case EventCategory.other:      return Icons.event_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.fun:        return const Color(0xFF6366F1);
      case EventCategory.trip:       return const Color(0xFF2563EB);
      case EventCategory.meeting:    return const Color(0xFF059669);
      case EventCategory.graduation: return const Color(0xFF7C3AED);
      case EventCategory.sports:     return const Color(0xFFD97706);
      case EventCategory.cultural:   return const Color(0xFFEC4899);
      case EventCategory.other:      return const Color(0xFF64748B);
    }
  }

  static EventCategory fromString(String? v) {
    return EventCategory.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EventCategory.other,
    );
  }
}

class NurseryEventModel {
  final String id;
  final String nurseryId;
  final String? branchId;
  final String title;
  final String description;
  final int date;
  final String? timeStr;
  final String? location;
  final String? coverImage;
  final EventCategory category;
  /// Ticket/participation fee. Null or 0 means the event is free.
  final double? price;
  final String createdBy;
  final String createdByName;
  final int createdAt;
  final int attendeesCount;
  final bool isActive;

  /// Event photos, keyed `photoId → ActivityPhoto`. Any staff member may upload
  /// (stored `isApproved = false`); a reviewer approves them for guardians.
  /// Reuses the generic [ActivityPhoto] model — `classroom` audience means
  /// "everyone", `children` means specific children's guardians.
  final Map<String, ActivityPhoto> photos;

  /// How many days the event's photo carousel stays on the parents' home after
  /// the photos are published. 0 = never show the home banner. Set by the
  /// reviewer (manager/owner) when approving the photos.
  final int photosBannerDays;

  /// When the event's photos were approved/published (ms).
  final int? photosPublishedAt;

  /// Id of the social-feed gallery post created when the photos were published
  /// — lets a re-approval update that same post instead of creating a new one.
  final String? photosPostId;

  const NurseryEventModel({
    required this.id,
    required this.nurseryId,
    this.branchId,
    required this.title,
    required this.description,
    required this.date,
    this.timeStr,
    this.location,
    this.coverImage,
    this.category = EventCategory.other,
    this.price,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.attendeesCount = 0,
    this.isActive = true,
    this.photos = const {},
    this.photosBannerDays = 0,
    this.photosPublishedAt,
    this.photosPostId,
  });

  bool get isUpcoming => date > DateTime.now().millisecondsSinceEpoch;

  // ── Photo helpers (mirror ClassroomActivityModel) ──────────────────────────

  /// Every photo URL regardless of approval — staff-facing views.
  List<String> get allPhotoUrls =>
      photos.values.map((p) => p.url).where((u) => u.isNotEmpty).toList();

  /// Approved photo URLs a specific child's guardian may see (everyone or
  /// targeted to that child) — the guardian-facing filter.
  List<String> approvedUrlsForChild(String childId) => photos.values
      .where((p) => p.isApproved && p.visibleTo(childId))
      .map((p) => p.url)
      .where((u) => u.isNotEmpty)
      .toList();

  bool get hasPendingPhotos => photos.values.any((p) => !p.isApproved);

  int get pendingPhotoCount =>
      photos.values.where((p) => !p.isApproved).length;

  /// A real fee was set (parents should be shown the amount); otherwise free.
  bool get hasPrice => price != null && price! > 0;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  String get formattedDate {
    final d = dateTime;
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  factory NurseryEventModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return NurseryEventModel(
      id: id,
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: _parseInt(json['date']) ?? DateTime.now().millisecondsSinceEpoch,
      timeStr: json['timeStr']?.toString(),
      location: json['location']?.toString(),
      coverImage: json['coverImage']?.toString(),
      category: EventCategory.fromString(json['category']?.toString()),
      price: _parseDouble(json['price']),
      createdBy: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      attendeesCount: _parseInt(json['attendeesCount']) ?? 0,
      isActive: json['isActive'] != false,
      photos: _parsePhotos(json['photos']),
      photosBannerDays: _parseInt(json['photosBannerDays']) ?? 0,
      photosPublishedAt: _parseInt(json['photosPublishedAt']),
      photosPostId: json['photosPostId']?.toString(),
    );
  }


  static Map<String, ActivityPhoto> _parsePhotos(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final out = <String, ActivityPhoto>{};
    for (final e in raw.entries) {
      final id = e.key.toString();
      out[id] = ActivityPhoto.fromValue(id, e.value);
    }
    return out;
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'nurseryId': nurseryId,
      'title': title,
      'description': description,
      'date': date,
      'category': category.name,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
      'attendeesCount': attendeesCount,
      'isActive': isActive,
    };
    if (branchId != null) m['branchId'] = branchId;
    if (timeStr != null) m['timeStr'] = timeStr;
    if (location != null) m['location'] = location;
    if (coverImage != null) m['coverImage'] = coverImage;
    if (price != null) m['price'] = price;
    return m;
  }

  NurseryEventModel copyWith({
    String? id,
    String? nurseryId,
    String? branchId,
    String? title,
    String? description,
    int? date,
    String? timeStr,
    String? location,
    String? coverImage,
    EventCategory? category,
    double? price,
    String? createdBy,
    String? createdByName,
    int? createdAt,
    int? attendeesCount,
    bool? isActive,
    Map<String, ActivityPhoto>? photos,
    int? photosBannerDays,
    int? photosPublishedAt,
    String? photosPostId,
  }) =>
      NurseryEventModel(
        id: id ?? this.id,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        timeStr: timeStr ?? this.timeStr,
        location: location ?? this.location,
        coverImage: coverImage ?? this.coverImage,
        category: category ?? this.category,
        price: price ?? this.price,
        createdBy: createdBy ?? this.createdBy,
        createdByName: createdByName ?? this.createdByName,
        createdAt: createdAt ?? this.createdAt,
        attendeesCount: attendeesCount ?? this.attendeesCount,
        isActive: isActive ?? this.isActive,
        photos: photos ?? this.photos,
        photosBannerDays: photosBannerDays ?? this.photosBannerDays,
        photosPublishedAt: photosPublishedAt ?? this.photosPublishedAt,
        photosPostId: photosPostId ?? this.photosPostId,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
