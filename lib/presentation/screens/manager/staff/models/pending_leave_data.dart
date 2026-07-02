/// A leave request awaiting the manager's review.
class PendingLeaveData {
  const PendingLeaveData({
    required this.leaveId,
    required this.staffId,
    required this.staffName,
    required this.roleKey,
    required this.typeKey,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  final String leaveId;
  final String staffId;
  final String staffName;

  /// Translation key for the staff member's role.
  final String roleKey;

  /// Translation key for the leave type (annual / sick / emergency / unpaid).
  final String typeKey;

  final int startDate; // epoch ms
  final int endDate; // epoch ms
  final int days;
}
