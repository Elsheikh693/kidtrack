/// A child who has not attended for a prolonged period (>= threshold days).
class LongAbsenceData {
  final String childId;
  final String name;
  final String classroomName;
  final int days;

  const LongAbsenceData({
    required this.childId,
    required this.name,
    required this.classroomName,
    required this.days,
  });
}
