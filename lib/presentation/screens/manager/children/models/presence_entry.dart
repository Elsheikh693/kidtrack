/// One child's live presence on the current school day: when they checked in
/// and, if they have already gone home, when they were checked out.
class PresenceEntry {
  final String childId;
  final String name;
  final String classroomName;
  final String? imageUrl;
  final int? checkInMs;
  final int? checkOutMs;

  const PresenceEntry({
    required this.childId,
    required this.name,
    required this.classroomName,
    this.imageUrl,
    this.checkInMs,
    this.checkOutMs,
  });

  bool get isInside => checkOutMs == null;
}
