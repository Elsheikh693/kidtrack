/// A child flagged for manager attention, with the union of reasons that
/// raised the flag (follow-up note, serious incident, weak assessment).
class ChildRiskData {
  final String childId;
  final String name;
  final String classroomName;
  final List<String> reasonKeys;

  const ChildRiskData({
    required this.childId,
    required this.name,
    required this.classroomName,
    required this.reasonKeys,
  });

  /// More reasons = higher priority in the list ordering.
  int get severity => reasonKeys.length;
}
