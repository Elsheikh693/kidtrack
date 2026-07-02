/// Aggregated monthly payroll for one staff role (teacher, nanny, …).
class SalaryBandData {
  const SalaryBandData({
    required this.roleKey,
    required this.count,
    required this.total,
  });

  /// Translation key for the role label.
  final String roleKey;

  /// Number of staff in this role that have a salary set.
  final int count;

  /// Combined monthly salary for the role.
  final double total;
}
