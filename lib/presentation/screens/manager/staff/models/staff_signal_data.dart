/// A single staff member surfaced in the Workforce Signals section
/// (absent today, unassigned teacher, …). Carries only what the row renders.
class StaffSignalData {
  const StaffSignalData({
    required this.staffId,
    required this.name,
    required this.roleKey,
  });

  final String staffId;
  final String name;

  /// Translation key for the staff member's role (e.g. `template_teacher`).
  final String roleKey;
}
