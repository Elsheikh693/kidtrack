import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

// ── BusLocation ───────────────────────────────────────────────────────────────

class BusLocation extends Equatable {
  final double lat;
  final double lng;
  final int updatedAt;

  const BusLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  factory BusLocation.fromJson(Map<dynamic, dynamic> json) => BusLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        updatedAt: json['updatedAt'] as int,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'updatedAt': updatedAt,
      };

  @override
  List<Object?> get props => [lat, lng, updatedAt];
}

// ── BusTripDirection ──────────────────────────────────────────────────────────

// toHome    = من الحضانة إلى البيوت (بعد الضهر)
// toNursery = من البيوت إلى الحضانة (الصبح)
enum BusTripDirection { toHome, toNursery }

extension BusTripDirectionX on BusTripDirection {
  static BusTripDirection fromString(String? v) => BusTripDirection.values
      .firstWhere((e) => e.name == v, orElse: () => BusTripDirection.toHome);

  String get label {
    switch (this) {
      case BusTripDirection.toHome:
        return 'tracking_dir_to_home'.tr;
      case BusTripDirection.toNursery:
        return 'tracking_dir_to_nursery'.tr;
    }
  }

  // نص زر "ركب الحافلة" (وقت الاستلام)
  String get pickupLabel {
    switch (this) {
      case BusTripDirection.toHome:
        return 'tracking_btn_on_bus'.tr; // ركب من الحضانة
      case BusTripDirection.toNursery:
        return 'tracking_btn_picked_home'.tr; // ركب من البيت
    }
  }

  // نص زر "وصل" (وقت التسليم)
  String get deliverLabel {
    switch (this) {
      case BusTripDirection.toHome:
        return 'tracking_btn_delivered'.tr; // وصل للبيت
      case BusTripDirection.toNursery:
        return 'tracking_btn_arrived_nursery'.tr; // وصل للحضانة
    }
  }
}

// ── ChildBusStatus ────────────────────────────────────────────────────────────

enum ChildBusStatus { pending, onBus, delivered }

extension ChildBusStatusX on ChildBusStatus {
  static ChildBusStatus fromString(String? v) => ChildBusStatus.values
      .firstWhere((e) => e.name == v, orElse: () => ChildBusStatus.pending);

  String get label {
    switch (this) {
      case ChildBusStatus.pending:
        return 'tracking_child_pending'.tr;
      case ChildBusStatus.onBus:
        return 'tracking_child_on_bus'.tr;
      case ChildBusStatus.delivered:
        return 'tracking_child_delivered'.tr;
    }
  }
}

// ── BusChildEntry ─────────────────────────────────────────────────────────────

class BusChildEntry extends Equatable {
  final String childId;
  final String childName;
  final String? childImage;
  final String? address;
  final double? homeLat;
  final double? homeLng;
  final String? parentId; // parent uid → for notifications
  final String? parentPhone; // for quick call
  final ChildBusStatus status;
  final int? pickedUpAt;
  final int? deliveredAt;
  final int? updatedAt;

  const BusChildEntry({
    required this.childId,
    required this.childName,
    this.childImage,
    this.address,
    this.homeLat,
    this.homeLng,
    this.parentId,
    this.parentPhone,
    required this.status,
    this.pickedUpAt,
    this.deliveredAt,
    this.updatedAt,
  });

  bool get hasLocation => homeLat != null && homeLng != null;

  factory BusChildEntry.fromJson(String id, Map<dynamic, dynamic> json) =>
      BusChildEntry(
        childId: id,
        childName: json['childName'] as String? ?? '',
        childImage: json['childImage'] as String?,
        address: json['address'] as String?,
        homeLat: (json['homeLat'] as num?)?.toDouble(),
        homeLng: (json['homeLng'] as num?)?.toDouble(),
        parentId: json['parentId'] as String?,
        parentPhone: json['parentPhone'] as String?,
        status: ChildBusStatusX.fromString(json['status'] as String?),
        pickedUpAt: json['pickedUpAt'] as int?,
        deliveredAt: json['deliveredAt'] as int?,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'childName': childName,
        'childImage': childImage,
        'address': address,
        'homeLat': homeLat,
        'homeLng': homeLng,
        'parentId': parentId,
        'parentPhone': parentPhone,
        'status': status.name,
        'pickedUpAt': pickedUpAt,
        'deliveredAt': deliveredAt,
        'updatedAt': updatedAt,
      };

  BusChildEntry copyWith({
    ChildBusStatus? status,
    int? pickedUpAt,
    int? deliveredAt,
    int? updatedAt,
  }) =>
      BusChildEntry(
        childId: childId,
        childName: childName,
        childImage: childImage,
        address: address,
        homeLat: homeLat,
        homeLng: homeLng,
        parentId: parentId,
        parentPhone: parentPhone,
        status: status ?? this.status,
        pickedUpAt: pickedUpAt ?? this.pickedUpAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props =>
      [childId, status, pickedUpAt, deliveredAt, updatedAt];
}

// ── BusSession ────────────────────────────────────────────────────────────────

class BusSession extends Equatable {
  final String sessionId;
  final String chaperoneId;
  final String chaperoneName;
  final String branchId;
  final BusTripDirection direction;
  final int date; // day-start ms (for history grouping/filter)
  final BusLocation? location;
  final String status; // "active" | "completed"
  final List<BusChildEntry> children;
  final int createdAt;
  final int? endedAt;

  const BusSession({
    required this.sessionId,
    required this.chaperoneId,
    required this.chaperoneName,
    required this.branchId,
    this.direction = BusTripDirection.toHome,
    this.date = 0,
    this.location,
    required this.status,
    required this.children,
    required this.createdAt,
    this.endedAt,
  });

  factory BusSession.fromJson(String id, Map<dynamic, dynamic> json) {
    final childrenRaw = json['children'] as Map? ?? {};
    final children = childrenRaw.entries
        .map((e) => BusChildEntry.fromJson(
              e.key.toString(),
              e.value as Map<dynamic, dynamic>,
            ))
        .toList();

    BusLocation? location;
    if (json['location'] != null) {
      location = BusLocation.fromJson(json['location'] as Map<dynamic, dynamic>);
    }

    return BusSession(
      sessionId: id,
      chaperoneId: json['chaperoneId'] as String? ?? '',
      chaperoneName: json['chaperoneName'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      direction: BusTripDirectionX.fromString(json['direction'] as String?),
      date: json['date'] as int? ?? 0,
      location: location,
      status: json['status'] as String? ?? 'active',
      children: children,
      createdAt: json['createdAt'] as int? ?? 0,
      endedAt: json['endedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chaperoneId': chaperoneId,
        'chaperoneName': chaperoneName,
        'branchId': branchId,
        'direction': direction.name,
        'date': date,
        'location': location?.toJson(),
        'status': status,
        'children': {
          for (final c in children) c.childId: c.toJson(),
        },
        'createdAt': createdAt,
        'endedAt': endedAt,
      };

  bool get isActive => status == 'active';

  int get deliveredCount =>
      children.where((c) => c.status == ChildBusStatus.delivered).length;

  @override
  List<Object?> get props => [sessionId, status, location, children];
}
