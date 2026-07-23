import 'package:flutter/material.dart';

/// One class that is currently in session — a single slice of the live
/// teaching donut on the manager home. Carries everything the slice, its
/// legend row and the drill-down need, already resolved to display values.
class TeachingSlice {
  final String classroomId;
  final String className;

  /// The subject being taught right now (e.g. "Arabic"), falling back to a
  /// generic label so the donut arc always reads as a topic, never a blank.
  final String subjectLabel;

  /// The specific activity/lesson being run (e.g. "شرح حرف الكاف"). May be empty
  /// when the teacher started a subject with no lesson title.
  final String activityTitle;

  final String teacherId;
  final String teacherName;
  final String? teacherPhoto;

  /// When the running activity started — used to sort slices deterministically
  /// and to drive the live elapsed timer on the card.
  final int startedAt;

  /// True when this is a subset "نشاط" (specific children) rather than a
  /// whole-class "حصة" session. Drives the mode badge and accent color.
  final bool isActivityMode;

  /// How many children are in the running activity — shown for activity-mode
  /// cards ("3 أطفال"). Ignored for whole-class sessions.
  final int participantCount;

  /// Categorical color for this slice, assigned by the controller.
  final Color color;

  const TeachingSlice({
    required this.classroomId,
    required this.className,
    required this.subjectLabel,
    required this.activityTitle,
    required this.teacherId,
    required this.teacherName,
    this.teacherPhoto,
    required this.startedAt,
    this.isActivityMode = false,
    this.participantCount = 0,
    required this.color,
  });
}
