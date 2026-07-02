import 'package:flutter/material.dart';

enum HomeworkStatus { completed, partiallyCompleted, notCompleted, absent }

extension HomeworkStatusX on HomeworkStatus {
  String get key => switch (this) {
        HomeworkStatus.completed => 'completed',
        HomeworkStatus.partiallyCompleted => 'partial',
        HomeworkStatus.notCompleted => 'not_completed',
        HomeworkStatus.absent => 'absent',
      };

  String get label => switch (this) {
        HomeworkStatus.completed => 'أكمل',
        HomeworkStatus.partiallyCompleted => 'جزئي',
        HomeworkStatus.notCompleted => 'لم يكمل',
        HomeworkStatus.absent => 'غائب',
      };

  Color get color => switch (this) {
        HomeworkStatus.completed => const Color(0xFF16A34A),
        HomeworkStatus.partiallyCompleted => const Color(0xFFD97706),
        HomeworkStatus.notCompleted => const Color(0xFFDC2626),
        HomeworkStatus.absent => const Color(0xFF6B7280),
      };

  IconData get icon => switch (this) {
        HomeworkStatus.completed => Icons.check_circle_rounded,
        HomeworkStatus.partiallyCompleted => Icons.incomplete_circle_rounded,
        HomeworkStatus.notCompleted => Icons.cancel_rounded,
        HomeworkStatus.absent => Icons.person_off_rounded,
      };

  static HomeworkStatus fromKey(String k) => switch (k) {
        'completed' => HomeworkStatus.completed,
        'partial' => HomeworkStatus.partiallyCompleted,
        'not_completed' => HomeworkStatus.notCompleted,
        'absent' => HomeworkStatus.absent,
        // backwards compat
        'solved' => HomeworkStatus.completed,
        'not_solved' => HomeworkStatus.notCompleted,
        _ => HomeworkStatus.notCompleted,
      };
}

class HomeworkStatusModel {
  final String homeworkId;
  final String childId;
  final String nurseryId;
  final String classroomId;
  final HomeworkStatus status;
  final String markedBy;
  final int markedAt;

  const HomeworkStatusModel({
    required this.homeworkId,
    required this.childId,
    required this.nurseryId,
    required this.classroomId,
    required this.status,
    required this.markedBy,
    required this.markedAt,
  });

  factory HomeworkStatusModel.fromJson(
    Map<dynamic, dynamic> json, {
    required String homeworkId,
    required String childId,
  }) {
    return HomeworkStatusModel(
      homeworkId: homeworkId,
      childId: childId,
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      status: HomeworkStatusX.fromKey(json['status']?.toString() ?? ''),
      markedBy: json['markedBy']?.toString() ?? '',
      markedAt: _int(json['markedAt']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'homeworkId': homeworkId,
        'childId': childId,
        'nurseryId': nurseryId,
        'classroomId': classroomId,
        'status': status.key,
        'markedBy': markedBy,
        'markedAt': markedAt,
      };

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
