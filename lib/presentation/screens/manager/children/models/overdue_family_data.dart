/// A family (parent) with one or more overdue invoices, aggregated for the
/// Children tab's collection-risk view.
class OverdueFamilyData {
  final String parentId;
  final String parentName;
  final int invoiceCount;
  final double totalAmount;

  const OverdueFamilyData({
    required this.parentId,
    required this.parentName,
    required this.invoiceCount,
    required this.totalAmount,
  });
}
