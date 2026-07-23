import '../core/branch_scoped.dart';

/// One "Star of the Week" (نجم الأسبوع) record: the manager-picked ideal child
/// for a given week, together with the celebratory caption that also becomes a
/// feed post. Branch-scoped, and keyed deterministically as
/// `{branchId}__{weekKey}` so re-picking within the same week overwrites the
/// existing record instead of creating a duplicate.
class StarOfWeekModel implements BranchScoped {
  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  final String? key;
  final String nurseryId;
  final String branchId;

  /// Saturday-start week identifier, formatted `yyyy-MM-dd` (the week's
  /// Saturday). Weeks start on Saturday to match the rest of the app.
  final String weekKey;

  final String childId;
  final String childName;
  final String? childPhotoUrl;

  /// Manager-written celebration text; reused as the feed post caption.
  final String caption;

  final String pickedById;
  final String pickedByName;

  /// The feed post created from this pick (so the record and its social post
  /// stay linked). Null until the post is published.
  final String? postId;

  final int createdAt;

  const StarOfWeekModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.weekKey,
    required this.childId,
    required this.childName,
    this.childPhotoUrl,
    required this.caption,
    required this.pickedById,
    required this.pickedByName,
    this.postId,
    required this.createdAt,
  });

  /// Deterministic id for a pick: one star per branch per week.
  static String idFor(String branchId, String weekKey) =>
      '${branchId}__$weekKey';

  /// The Saturday that opens the week containing [date], as `yyyy-MM-dd`.
  static String weekKeyFor(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    // Days since the most recent Saturday (weekday 6).
    final daysSinceSat = (today.weekday - DateTime.saturday + 7) % 7;
    final start = today.subtract(Duration(days: daysSinceSat));
    final m = start.month.toString().padLeft(2, '0');
    final d = start.day.toString().padLeft(2, '0');
    return '${start.year}-$m-$d';
  }

  static String currentWeekKey() => weekKeyFor(DateTime.now());

  bool get isCurrentWeek => weekKey == currentWeekKey();

  factory StarOfWeekModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return StarOfWeekModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      weekKey: json['weekKey']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      childPhotoUrl: json['childPhotoUrl']?.toString(),
      caption: json['caption']?.toString() ?? '',
      pickedById: json['pickedById']?.toString() ?? '',
      pickedByName: json['pickedByName']?.toString() ?? '',
      postId: json['postId']?.toString(),
      createdAt: _parseInt(json['createdAt']) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nurseryId': nurseryId,
      'branchId': branchId,
      'weekKey': weekKey,
      'childId': childId,
      'childName': childName,
      'caption': caption,
      'pickedById': pickedById,
      'pickedByName': pickedByName,
      'createdAt': createdAt,
    };
    if (childPhotoUrl != null) data['childPhotoUrl'] = childPhotoUrl;
    if (postId != null) data['postId'] = postId;
    return data;
  }

  StarOfWeekModel copyWith({
    String? key,
    String? nurseryId,
    String? branchId,
    String? weekKey,
    String? childId,
    String? childName,
    String? childPhotoUrl,
    String? caption,
    String? pickedById,
    String? pickedByName,
    String? postId,
    int? createdAt,
  }) =>
      StarOfWeekModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        weekKey: weekKey ?? this.weekKey,
        childId: childId ?? this.childId,
        childName: childName ?? this.childName,
        childPhotoUrl: childPhotoUrl ?? this.childPhotoUrl,
        caption: caption ?? this.caption,
        pickedById: pickedById ?? this.pickedById,
        pickedByName: pickedByName ?? this.pickedByName,
        postId: postId ?? this.postId,
        createdAt: createdAt ?? this.createdAt,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
