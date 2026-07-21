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

  /// Generates any missing invoices for [month] (only when [month] is the
  /// current calendar month), then RETURNS the full invoice list — so the caller
  /// renders dues without a second read. The three lookups run in parallel to
  /// keep the reception collections screen fast. When [branchId] is given, only
  /// children of that branch are billed (reception scope).
  Future<List<InvoiceModel>> generateForMonth({
    required DateTime month,
    String? branchId,
  }) async {
    final now = DateTime.now();
    final nurseryId = SessionService().nurseryId ?? '';

    // Children (billable), packages, and existing invoices — all at once.
    final children = <ChildModel>[];
    final packages = <String, PackageModel>{};
    final allInvoices = <InvoiceModel>[];
    final existingKeys = <String>{};
    await Future.wait([
      _childSvc.getAll(callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          if (c.key == null || c.status != 'active') continue;
          if (c.packageIds.isEmpty) continue;
          if (branchId != null &&
              branchId.isNotEmpty &&
              c.branchId != branchId) {
            continue;
          }
          children.add(c);
        }
      }),
      _packageSvc.getAll(callBack: (list) {
        for (final p in list.whereType<PackageModel>()) {
          if (p.key != null) packages[p.key!] = p;
        }
      }),
      _invoiceSvc.getAll(callBack: (list) {
        for (final inv in list.whereType<InvoiceModel>()) {
          allInvoices.add(inv);
          if (inv.key != null) existingKeys.add(inv.key!);
        }
      }),
    ]);

    // Only the current month is ever generated; history months read-only.
    final isCurrent = month.year == now.year && month.month == now.month;
    if (!isCurrent || nurseryId.isEmpty || children.isEmpty) return allInvoices;

    final dueDate =
        DateTime(month.year, month.month, 1).millisecondsSinceEpoch;

    for (final child in children) {
      final childPkgs = child.packageIds
          .map((id) => packages[id])
          .whereType<PackageModel>()
          .where((p) => p.isActive)
          .toList();
      if (childPkgs.isEmpty) continue;

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
      allInvoices.add(invoice);
    }
    return allInvoices;
  }

  /// How many days before month-end the NEXT month's invoice opens for early
  /// payment ("pay ahead"). In the last [_payAheadWindowDays] days the guardian
  /// sees next month's due so they can settle it before the month starts —
  /// roughly a week before the month ends.
  static const int _payAheadWindowDays = 7;

  /// The months to bill for [now]: always the current month, plus next month
  /// once we're within the pay-ahead window near month-end.
  static List<DateTime> billingMonths(DateTime now) {
    final months = [DateTime(now.year, now.month)];
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    if (daysInMonth - now.day <= _payAheadWindowDays) {
      // DateTime normalises month 13 → January of next year.
      months.add(DateTime(now.year, now.month + 1));
    }
    return months;
  }

  /// Ensures the fee invoices exist for a SINGLE [childId] — used by the guardian
  /// app so a parent always sees their due (amount + date) and can pay it, even
  /// before reception opens the collections tab. Covers the current month plus,
  /// in the last [_payAheadWindowDays] days, next month too (pay ahead).
  /// Idempotent (deterministic key); no-op when the child is inactive or holds
  /// no active package.
  ///
  /// Returns ALL of the child's invoices (existing + any just created) so the
  /// caller can render outstanding dues WITHOUT a second round-trip — the three
  /// lookups run in parallel to keep the guardian screen fast.
  Future<List<InvoiceModel>> generateForChild(String childId) async {
    if (childId.isEmpty) return const [];
    final now = DateTime.now();

    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty) return const [];

    ChildModel? child;
    final childInvoices = <InvoiceModel>[];
    final existing = <String>{};
    final packages = <String, PackageModel>{};
    await Future.wait([
      _childSvc.getAll(callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          if (c.key == childId) {
            child = c;
            break;
          }
        }
      }),
      _invoiceSvc.getAll(callBack: (list) {
        for (final inv in list.whereType<InvoiceModel>()) {
          if (inv.childId != childId) continue;
          childInvoices.add(inv);
          if (inv.key != null) existing.add(inv.key!);
        }
      }),
      _packageSvc.getAll(callBack: (list) {
        for (final p in list.whereType<PackageModel>()) {
          if (p.key != null) packages[p.key!] = p;
        }
      }),
    ]);

    final c = child;
    if (c == null || c.status != 'active' || c.packageIds.isEmpty) {
      return childInvoices;
    }

    final months = billingMonths(now)
        .where((m) => !existing.contains(monthlyKey(childId, m)))
        .toList();
    if (months.isEmpty) return childInvoices;

    final childPkgs = c.packageIds
        .map((id) => packages[id])
        .whereType<PackageModel>()
        .where((p) => p.isActive)
        .toList();
    if (childPkgs.isEmpty) return childInvoices;

    final amount = childPkgs.fold<double>(0, (acc, p) => acc + p.monthlyDue);
    final title = childPkgs.map((p) => p.name).join(' + ');
    final packageId = childPkgs.length == 1 ? childPkgs.first.key : null;

    for (final month in months) {
      final invoice = InvoiceModel(
        key: monthlyKey(childId, month),
        nurseryId: nurseryId,
        childId: childId,
        parentId: c.parentId,
        packageId: packageId,
        title: title,
        amount: amount,
        totalAmount: amount,
        status: 'pending',
        dueDate: DateTime(month.year, month.month, 1).millisecondsSinceEpoch,
      );
      await _invoiceSvc.add(item: invoice, callBack: (_) {}, silent: true);
      childInvoices.add(invoice);
    }
    return childInvoices;
  }
}
