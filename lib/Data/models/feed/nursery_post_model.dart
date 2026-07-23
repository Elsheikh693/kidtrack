import '../core/branch_scoped.dart';

enum PostCategory {
  general,
  announcement,
  event,
  achievement,
  reminder,
  starOfWeek,
  // A photo-slider post (renders as a swipeable carousel instead of the collage
  // grid). Used for event-photo albums, and selectable for manual galleries.
  gallery;

  String get labelKey => 'feed_category_$name';

  static PostCategory fromString(String? v) {
    return PostCategory.values.firstWhere(
      (e) => e.name == v,
      orElse: () => PostCategory.general,
    );
  }
}

class NurseryPostModel implements BranchScoped {
  @override
  List<String> get scopeBranches => branchIds;

  final String id;
  final String nurseryId;
  // Empty list = visible in all branches; otherwise restricted to these branch ids.
  final List<String> branchIds;
  final String? classroomId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final List<String> photos;
  final PostCategory category;
  final bool isPinned;
  /// When a pin expires (ms). Null = pinned indefinitely (while [isPinned]).
  /// Past this moment the post drops out of the pinned section automatically.
  final int? pinnedUntil;
  final int createdAt;
  final int? updatedAt;
  // Distinct parents who have seen this post. Derived from the `seenBy/{uid}`
  // subtree, which is written separately from the post body (never in toJson).
  final int seenCount;

  const NurseryPostModel({
    required this.id,
    required this.nurseryId,
    this.branchIds = const [],
    this.classroomId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    this.photos = const [],
    this.category = PostCategory.general,
    this.isPinned = false,
    this.pinnedUntil,
    required this.createdAt,
    this.updatedAt,
    this.seenCount = 0,
  });

  bool get isAllBranches => branchIds.isEmpty;

  /// Whether this post is still pinned at [nowMs] — pinned and not yet expired.
  bool effectivePinnedAt(int nowMs) =>
      isPinned && (pinnedUntil == null || nowMs <= pinnedUntil!);

  bool get isGallery => category == PostCategory.gallery;

  factory NurseryPostModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return NurseryPostModel(
      id: id,
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchIds: _parseStringList(json['branchIds']),
      classroomId: json['classroomId']?.toString(),
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      authorPhotoUrl: json['authorPhotoUrl']?.toString(),
      text: json['text']?.toString() ?? '',
      photos: _parseList(json['photos']),
      category: PostCategory.fromString(json['category']?.toString()),
      isPinned: json['isPinned'] == true,
      pinnedUntil: _parseInt(json['pinnedUntil']),
      createdAt: _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: _parseInt(json['updatedAt']),
      seenCount: _countMap(json['seenBy']),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'nurseryId': nurseryId,
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'category': category.name,
      'isPinned': isPinned,
      'createdAt': createdAt,
    };
    if (pinnedUntil != null) m['pinnedUntil'] = pinnedUntil;
    if (branchIds.isNotEmpty) m['branchIds'] = branchIds;
    if (classroomId != null) m['classroomId'] = classroomId;
    if (authorPhotoUrl != null) m['authorPhotoUrl'] = authorPhotoUrl;
    if (photos.isNotEmpty) m['photos'] = photos;
    if (updatedAt != null) m['updatedAt'] = updatedAt;
    return m;
  }

  NurseryPostModel copyWith({
    String? id,
    String? nurseryId,
    List<String>? branchIds,
    String? classroomId,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? text,
    List<String>? photos,
    PostCategory? category,
    bool? isPinned,
    int? pinnedUntil,
    int? createdAt,
    int? updatedAt,
    int? seenCount,
  }) =>
      NurseryPostModel(
        id: id ?? this.id,
        nurseryId: nurseryId ?? this.nurseryId,
        branchIds: branchIds ?? this.branchIds,
        classroomId: classroomId ?? this.classroomId,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName,
        authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
        text: text ?? this.text,
        photos: photos ?? this.photos,
        category: category ?? this.category,
        isPinned: isPinned ?? this.isPinned,
        pinnedUntil: pinnedUntil ?? this.pinnedUntil,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        seenCount: seenCount ?? this.seenCount,
      );

  static List<String> _parseList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is Map) return v.values.map((e) => e.toString()).toList();
    return [];
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (v is Map) {
      return v.values.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static int _countMap(dynamic v) {
    if (v is Map) return v.length;
    if (v is List) return v.where((e) => e != null).length;
    return 0;
  }
}
