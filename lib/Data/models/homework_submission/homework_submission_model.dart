/// A PARENT'S confirmation that the homework was done at home, together with a
/// light "how did it go" self-report.
///
/// The old "who did it" (mother/father/self) field was dropped in favour of
/// three optional yes/no answers describing HOW the child did the homework:
///   • [neededHelp]  — احتاج مساعدة؟
///   • [guidedHand]  — مسكت إيده؟ (an adult physically guided the hand)
///   • [didEasily]   — عملها بسهولة؟
///
/// Each answer is nullable — the parent may confirm completion without
/// answering. Stored at
/// `platform/{nurseryId}/homeworkSubmissions/{homeworkId}/{childId}`.
class HomeworkSubmissionModel {
  final String homeworkId;
  final String childId;
  final String nurseryId;
  final String classroomId;
  final int submittedAt;
  final String submittedByUid;
  final bool? neededHelp;
  final bool? guidedHand;
  final bool? didEasily;
  final String? note;
  final String? photo;

  const HomeworkSubmissionModel({
    required this.homeworkId,
    required this.childId,
    required this.nurseryId,
    required this.classroomId,
    required this.submittedAt,
    required this.submittedByUid,
    this.neededHelp,
    this.guidedHand,
    this.didEasily,
    this.note,
    this.photo,
  });

  /// True when the parent answered at least one of the "how did it go" questions.
  bool get hasAnswers =>
      neededHelp != null || guidedHand != null || didEasily != null;

  factory HomeworkSubmissionModel.fromJson(
    Map<dynamic, dynamic> json, {
    required String homeworkId,
    required String childId,
  }) {
    return HomeworkSubmissionModel(
      homeworkId: homeworkId,
      childId: childId,
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      submittedAt: _int(json['submittedAt']) ?? 0,
      submittedByUid: json['submittedByUid']?.toString() ?? '',
      neededHelp: _bool(json['neededHelp']),
      guidedHand: _bool(json['guidedHand']),
      didEasily: _bool(json['didEasily']),
      note: (json['note']?.toString().trim().isEmpty ?? true)
          ? null
          : json['note'].toString(),
      photo: (json['photo']?.toString().trim().isEmpty ?? true)
          ? null
          : json['photo'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final d = <String, dynamic>{
      'nurseryId': nurseryId,
      'classroomId': classroomId,
      'submittedAt': submittedAt,
      'submittedByUid': submittedByUid,
    };
    if (neededHelp != null) d['neededHelp'] = neededHelp;
    if (guidedHand != null) d['guidedHand'] = guidedHand;
    if (didEasily != null) d['didEasily'] = didEasily;
    if ((note ?? '').trim().isNotEmpty) d['note'] = note!.trim();
    if ((photo ?? '').trim().isNotEmpty) d['photo'] = photo!.trim();
    return d;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static bool? _bool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }
}
