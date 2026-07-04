/// Aggregated health snapshot for a single classroom, used by the
/// Branch Manager Children tab's "Classroom Health" section.
class ClassHealthData {
  final String classroomId;
  final String name;

  /// Configured capacity, or null when the classroom has no capacity set —
  /// in that case we show the child count alone (never a fabricated ceiling).
  final int? capacity;
  final int enrolled;
  final int pending;
  final bool hasTeacher;

  /// Resolved name of the assigned teacher, or empty when none is assigned (or
  /// the staff record couldn't be found for [hasTeacher]).
  final String teacherName;

  /// A teacher currently has a running (status == 'active') activity in this
  /// classroom — a live signal, independent of the static teacher assignment.
  final bool hasActiveActivity;

  const ClassHealthData({
    required this.classroomId,
    required this.name,
    required this.capacity,
    required this.enrolled,
    required this.pending,
    required this.hasTeacher,
    this.teacherName = '',
    this.hasActiveActivity = false,
  });

  /// Whether a real capacity is configured. Drives the fill bar visibility.
  bool get hasCapacity => capacity != null && capacity! > 0;

  double get fillRate => hasCapacity ? enrolled / capacity! : 0;

  bool get isOverCapacity => hasCapacity && enrolled > capacity!;

  bool get isFull => hasCapacity && enrolled >= capacity!;

  bool get isAlmostFull => hasCapacity && !isFull && fillRate >= 0.85;

  /// Anything the manager should act on: missing teacher or over/at capacity.
  /// A running activity implies a teacher is present, so it isn't flagged as a
  /// missing-teacher issue.
  bool get hasIssue =>
      (!hasTeacher && !hasActiveActivity) || isFull || isOverCapacity;
}
