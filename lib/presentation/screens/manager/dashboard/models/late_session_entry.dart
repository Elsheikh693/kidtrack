/// A scheduled session whose start time (+grace) has passed while the classroom
/// still has no matching started activity — surfaced live on the manager
/// dashboard so she can nudge the teacher before it disrupts the day.
class LateSessionEntry {
  const LateSessionEntry({
    required this.slotId,
    required this.classroomId,
    required this.classroomName,
    required this.title,
    required this.teacherId,
    required this.teacherName,
    required this.startTime,
    required this.minutesLate,
  });

  final String slotId;
  final String classroomId;
  final String classroomName;
  final String title;
  final String teacherId;
  final String teacherName;
  final String startTime; // "09:00"
  final int minutesLate;
}
