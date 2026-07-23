/// Who an activity photo is delivered to.
/// `classroom` → every guardian in the classroom (the default, broadcast).
/// `children`  → only the guardians of [ActivityPhoto.targetChildren].
enum AudienceType {
  classroom,
  children;

  String get key => name;

  static AudienceType fromKey(String? k) =>
      k == 'children' ? AudienceType.children : AudienceType.classroom;
}

/// A single activity photo. Stored under
/// `classroomActivities/{classroomId}/{activityId}/photos/{photoId}`.
///
/// Teachers upload photos as `isApproved = false` (hidden from guardians); a
/// reviewer (manager / reception with the permission) deletes the bad ones and
/// hits Approve, which flips the rest to `isApproved = true` — the batch then
/// becomes visible to guardians. Each photo also carries its audience.
class ActivityPhoto {
  final String id;
  final String url;
  final bool isApproved;
  final AudienceType audienceType;
  final List<String> targetChildren; // ignored when audienceType == classroom
  final String? uploadedBy;
  final int? uploadedAt;
  final String? approvedBy;
  final int? approvedAt;

  const ActivityPhoto({
    required this.id,
    required this.url,
    this.isApproved = false,
    this.audienceType = AudienceType.classroom,
    this.targetChildren = const [],
    this.uploadedBy,
    this.uploadedAt,
    this.approvedBy,
    this.approvedAt,
  });

  bool get isClassroomWide => audienceType == AudienceType.classroom;

  /// Whether this photo should reach the given child's guardian.
  bool visibleTo(String childId) =>
      isClassroomWide || targetChildren.contains(childId);

  /// Parses a stored photo value. Handles the legacy shape where the value was
  /// just the download-URL string — those are treated as already approved and
  /// classroom-wide so existing photos never disappear (no migration needed).
  factory ActivityPhoto.fromValue(String id, dynamic raw) {
    if (raw is String) {
      return ActivityPhoto(id: id, url: raw, isApproved: true);
    }
    if (raw is Map) {
      return ActivityPhoto(
        id: id,
        url: raw['url']?.toString() ?? '',
        isApproved: _parseBool(raw['isApproved']),
        audienceType: AudienceType.fromKey(raw['audienceType']?.toString()),
        targetChildren: _parseStringList(raw['targetChildren']),
        uploadedBy: raw['uploadedBy']?.toString(),
        uploadedAt: _parseInt(raw['uploadedAt']),
        approvedBy: raw['approvedBy']?.toString(),
        approvedAt: _parseInt(raw['approvedAt']),
      );
    }
    return ActivityPhoto(id: id, url: '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'url': url,
      'isApproved': isApproved,
      'audienceType': audienceType.key,
    };
    if (targetChildren.isNotEmpty) data['targetChildren'] = targetChildren;
    if (uploadedBy != null) data['uploadedBy'] = uploadedBy;
    if (uploadedAt != null) data['uploadedAt'] = uploadedAt;
    if (approvedBy != null) data['approvedBy'] = approvedBy;
    if (approvedAt != null) data['approvedAt'] = approvedAt;
    return data;
  }

  ActivityPhoto copyWith({
    String? id,
    String? url,
    bool? isApproved,
    AudienceType? audienceType,
    List<String>? targetChildren,
    String? uploadedBy,
    int? uploadedAt,
    String? approvedBy,
    int? approvedAt,
  }) =>
      ActivityPhoto(
        id: id ?? this.id,
        url: url ?? this.url,
        isApproved: isApproved ?? this.isApproved,
        audienceType: audienceType ?? this.audienceType,
        targetChildren: targetChildren ?? this.targetChildren,
        uploadedBy: uploadedBy ?? this.uploadedBy,
        uploadedAt: uploadedAt ?? this.uploadedAt,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
      );

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is Map) return v.values.map((e) => e.toString()).toList();
    return const [];
  }
}
