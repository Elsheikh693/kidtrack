import 'package:flutter/material.dart';

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
  final String createdBy;
  final String createdByName;
  final int createdAt;
  final int attendeesCount;
  final bool isActive;

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
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.attendeesCount = 0,
    this.isActive = true,
  });

  bool get isUpcoming => date > DateTime.now().millisecondsSinceEpoch;

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
      createdBy: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      attendeesCount: _parseInt(json['attendeesCount']) ?? 0,
      isActive: json['isActive'] != false,
    );
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
    String? createdBy,
    String? createdByName,
    int? createdAt,
    int? attendeesCount,
    bool? isActive,
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
        createdBy: createdBy ?? this.createdBy,
        createdByName: createdByName ?? this.createdByName,
        createdAt: createdAt ?? this.createdAt,
        attendeesCount: attendeesCount ?? this.attendeesCount,
        isActive: isActive ?? this.isActive,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
