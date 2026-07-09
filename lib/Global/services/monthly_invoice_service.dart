import '../../index/index_main.dart';

/// Auto-generates one monthly fee invoice per active child that is subscribed
/// to a package, so "expected to collect this month" (المطلوب) is derived from
/// enrollment × package price instead of manual invoice entry.
///
/// Idempotent: each generated invoice uses a deterministic key
/// `month_{childId}_{YYYYMM}`, so re-running never creates duplicates. Only the
/// CURRENT calendar month is ever generated — browsing a history month must not
/// retroactively create invoices.
class MonthlyInvoiceService {
  final InvoiceParentService _invoiceSvc = Get.find<InvoiceParentService>();
  final ChildParentService _childSvc = Get.find<ChildParentService>();
  final PackageParentService _packageSvc = Get.find<PackageParentService>();

  static String monthlyKey(String childId, DateTime month) =>
      'month_${childId}_${month.year}${month.month.toString().padLeft(2, '0')}';

  /// Generates any missing invoices for [month]. No-op unless [month] is the
  /// current calendar month. When [branchId] is given, only children of that
  /// branch are billed (reception scope); pass null to bill the whole nursery.
  Future<void> generateForMonth({
    required DateTime month,
    String? branchId,
  }) async {
    final now = DateTime.now();
    if (month.year != now.year || month.month != now.month) return;

    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return;

    // Active children subscribed to a package (optionally within one branch).
    final children = <ChildModel>[];
    await _childSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ChildModel>()) {
        if (c.key == null || c.status != 'active') continue;
        if (c.packageIds.isEmpty) continue;
        if (branchId != null && branchId.isNotEmpty && c.branchId != branchId) {
          continue;
        }
        children.add(c);
      }
    });
    if (children.isEmpty) return;

    // packageId -> package (only active packages bill).
    final packages = <String, PackageModel>{};
    await _packageSvc.getAll(callBack: (list) {
      for (final p in list.whereType<PackageModel>()) {
        if (p.key != null) packages[p.key!] = p;
      }
    });

    // Existing invoice keys, to skip children already billed this month.
    final existingKeys = <String>{};
    await _invoiceSvc.getAll(callBack: (list) {
      for (final inv in list.whereType<InvoiceModel>()) {
        if (inv.key != null) existingKeys.add(inv.key!);
      }
    });

    final dueDate =
        DateTime(month.year, month.month, 1).millisecondsSinceEpoch;

    for (final child in children) {
      // Only active packages bill; a child may hold several.
      final childPkgs = child.packageIds
          .map((id) => packages[id])
          .whereType<PackageModel>()
          .where((p) => p.isActive)
          .toList();
      if (childPkgs.isEmpty) continue; // all packages removed/inactive

      final key = monthlyKey(child.key!, month);
      if (existingKeys.contains(key)) continue;

      final amount = childPkgs.fold<double>(0, (acc, p) => acc + p.monthlyDue);
      final invoice = InvoiceModel(
        key: key,
        nurseryId: nurseryId,
        childId: child.key!,
        parentId: child.parentId,
        packageId: childPkgs.length == 1 ? childPkgs.first.key : null,
        title: childPkgs.map((p) => p.name).join(' + '),
        amount: amount,
        totalAmount: amount,
        status: 'pending',
        dueDate: dueDate,
      );

      await _invoiceSvc.add(item: invoice, callBack: (_) {}, silent: true);
    }
  }
}
