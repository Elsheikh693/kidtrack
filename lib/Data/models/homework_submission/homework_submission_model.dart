/// Who helped the child complete the homework at home.
enum SubmittedBy { mother, father, self, other }

extension SubmittedByX on SubmittedBy {
  String get key => switch (this) {
        SubmittedBy.mother => 'mother',
        SubmittedBy.father => 'father',
        SubmittedBy.self => 'self',
        SubmittedBy.other => 'other',
      };

  String get label => switch (this) {
        SubmittedBy.mother => 'الأم',
        SubmittedBy.father => 'الأب',
        SubmittedBy.self => 'بنفسه',
        SubmittedBy.other => 'آخر',
      };

  static SubmittedBy fromKey(String? k) => switch (k) {
        'mother' => SubmittedBy.mother,
        'father' => SubmittedBy.father,
        'self' => SubmittedBy.self,
        _ => SubmittedBy.other,
      };
}

/// A PARENT'S confirmation that the homework was done at home.
///
/// This is a pure completion EVENT — it carries no quality judgment. The
/// teacher's assessment is a separate "review" ([HomeworkStatusModel]).
/// Stored at `platform/{nurseryId}/homeworkSubmissions/{homeworkId}/{childId}`.
class HomeworkSubmissionModel {
  final String homeworkId;
  final String childId;
  final String nurseryId;
  final String classroomId;
  final int submittedAt;
  final SubmittedBy submittedBy;
  final String submittedByUid;
  final String? note;
  final String? photo;

  const HomeworkSubmissionModel({
    required this.homeworkId,
    required this.childId,
    required this.nurseryId,
    required this.classroomId,
    required this.submittedAt,
    this.submittedBy = SubmittedBy.other,
    required this.submittedByUid,
    this.note,
    this.photo,
  });

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
      submittedBy: SubmittedByX.fromKey(json['submittedBy']?.toString()),
      submittedByUid: json['submittedByUid']?.toString() ?? '',
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
      'submittedBy': submittedBy.key,
      'submittedByUid': submittedByUid,
    };
    if ((note ?? '').trim().isNotEmpty) d['note'] = note!.trim();
    if ((photo ?? '').trim().isNotEmpty) d['photo'] = photo!.trim();
    return d;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
