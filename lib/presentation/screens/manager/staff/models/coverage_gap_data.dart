/// An active classroom that currently has no teacher assigned — a coverage gap
/// the manager needs to close.
class CoverageGapData {
  const CoverageGapData({
    required this.classroomId,
    required this.name,
  });

  final String classroomId;
  final String name;
}
