import 'package:flutter/material.dart';

/// One class that is currently in session — a single slice of the live
/// teaching donut on the manager home. Carries everything the slice, its
/// legend row and the drill-down need, already resolved to display values.
class TeachingSlice {
  final String classroomId;
  final String className;

  /// What is being taught right now — the activity's subject, falling back to
  /// its title so the arc always reads as a topic, never a blank.
  final String subjectLabel;

  final String teacherId;
  final String teacherName;
  final String? teacherPhoto;

  /// When the running activity started — used to sort slices deterministically.
  final int startedAt;

  /// Categorical color for this slice, assigned by the controller.
  final Color color;

  const TeachingSlice({
    required this.classroomId,
    required this.className,
    required this.subjectLabel,
    required this.teacherId,
    required this.teacherName,
    this.teacherPhoto,
    required this.startedAt,
    required this.color,
  });
}
