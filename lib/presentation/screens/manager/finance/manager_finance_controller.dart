import '../../../../index/index_main.dart';
import 'models/monthly_payment_row.dart';

/// Drives the manager's Payments screen — a single monthly subscription/
/// enrollment ledger. For the selected month it lists every child with money
/// due (subscriptions, enrolments, uniforms…) and whether they have paid or
/// still owe a balance. Stepping the month back is how the manager reviews past
/// "reports". The aggregate fields at the top (collected / outstanding /
/// overdue / debt families) are also consumed by the manager home dashboard.
class ManagerFinanceController extends GetxController {
  // ─── Dashboard aggregates (current month / live) ────────────────────────
  final collectedThisMonth = 0.0.obs;
  final outstandingTotal = 0.0.obs;
  final overdueTotal = 0.0.obs;
  final debtFamiliesCount = 0.obs;

  // ─── Monthly ledger view ────────────────────────────────────────────────
  /// First day of the month currently in view. Defaults to the live month.
  final anchorMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  /// Per-child rows for [anchorMonth] after search + status filter.
  final monthRows = <MonthlyPaymentRow>[].obs;

  /// 'all' | 'paid' | 'due'.
  final rowFilter = 'all'.obs;
  final searchQuery = ''.obs;

  final isLoading = true.obs;

  late final ChildParentService _childSvc;
  late final InvoiceParentService _invoiceSvc;
  late final GuardianParentService _guardianSvc;

  late Worker _searchWorker;

  final _session = SessionService();
  final _branchChildKeys = <String>{};
  final _childNames = <String, String>{};
  final _childParent = <String, String?>{};
  final _parentNames = <String, String>{};

  /// All invoices for this branch's children, kept in memory so stepping
  /// between months is instant (no refetch).
  final _branchInvoices = <InvoiceModel>[];

  /// Every row for [anchorMonth] before search/filter — backs the summary.
  final _allMonthRows = <MonthlyPaymentRow>[];

  String get branchId => _session.branchId ?? '';

  // ─── Selected-month summary (built from [_allMonthRows]) ─────────────────
  double get monthBilled =>
      _allMonthRows.fold<double>(0, (a, r) => a + r.billed);
  double get monthCollected =>
      _allMonthRows.fold<double>(0, (a, r) => a + r.collected);
  double get monthRemaining =>
      _allMonthRows.fold<double>(0, (a, r) => a + r.remaining);
  int get paidCount => _allMonthRows.where((r) => r.isPaid).length;
  int get dueCount => _allMonthRows.where((r) => !r.isPaid).length;
  int get monthChildCount => _allMonthRows.length;

  /// Share of the month's billable that has been collected (0–100).
  int get monthCollectionRate {
    final billed = monthBilled;
    if (billed <= 0) return 0;
    return ((monthCollected / billed) * 100).round().clamp(0, 100);
  }

  String get monthLabel => arabicMonthYear(anchorMonth.value);

  /// Can't browse into the future — the live month is the newest.
  bool get canGoForward {
    final now = DateTime.now();
    final a = anchorMonth.value;
    return a.year < now.year || (a.year == now.year && a.month < now.month);
  }

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _invoiceSvc = Get.find<InvoiceParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    _searchWorker = debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
    loadData();
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    super.onClose();
  }

  void onSearch(String value) => searchQuery.value = value;

  void onFilter(String filter) {
    rowFilter.value = filter;
    _applyFilter();
  }

  void previousMonth() {
    final a = anchorMonth.value;
    anchorMonth.value = DateTime(a.year, a.month - 1);
    _rebuildMonth();
  }

  void nextMonth() {
    if (!canGoForward) return;
    final a = anchorMonth.value;
    anchorMonth.value = DateTime(a.year, a.month + 1);
    _rebuildMonth();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    // Phase 1: children + guardians are independent — fetch together.
    await Future.wait([_loadChildren(), _loadGuardians()]);
    // Phase 2: invoices needs children+guardians.
    await _loadInvoices();
    _rebuildMonth();
    isLoading.value = false;
  }

  Future<void> _loadChildren() async {
    await _childSvc.getAll(callBack: (list) {
      final branch = list
          .whereType<ChildModel>()
          .where((c) =>
              c.branchId == branchId &&
              c.status == 'active' &&
              _session.seesShift(c.shift))
          .toList();
      _branchChildKeys
        ..clear()
        ..addAll(branch.where((c) => c.key != null).map((c) => c.key!));
      _childNames
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.fullName)));
      _childParent
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.parentId)));
    });
  }

  Future<void> _loadGuardians() async {
    await _guardianSvc.getAll(callBack: (list) {
      _parentNames
        ..clear()
        ..addEntries(
            list.whereType<ParentModel>().map((p) => MapEntry(p.uid, p.name)));
    });
  }

  Future<void> _loadInvoices() async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    await _invoiceSvc.getAll(callBack: (list) {
      _branchInvoices
        ..clear()
        ..addAll(list
            .whereType<InvoiceModel>()
            .where((inv) => _branchChildKeys.contains(inv.childId))
            .where((inv) => inv.status != 'cancelled'));

      // Live aggregates for the home dashboard (across all months).
      final unpaid = _branchInvoices.where(_isUnpaid).toList();
      // Outstanding folds each invoice's REMAINING balance, so a partially-paid
      // invoice only contributes what's still owed.
      outstandingTotal.value =
          unpaid.fold<double>(0, (acc, inv) => acc + inv.remaining);
      overdueTotal.value = unpaid
          .where((inv) => _isOverdue(inv, nowMs))
          .fold<double>(0, (acc, inv) => acc + inv.remaining);

      // Collected this month — folds each invoice's collected amount (full or
      // partial) using the SAME month logic as the payments ledger
      // (_rebuildMonth), so the home card and the payments screen never diverge.
      collectedThisMonth.value = _branchInvoices
          .where((inv) => inv.collectedAmount > 0)
          .where((inv) {
            final ms = inv.dueDate ?? inv.createdAt;
            if (ms == null) return false;
            final d = DateTime.fromMillisecondsSinceEpoch(ms);
            return d.year == now.year && d.month == now.month;
          })
          .fold<double>(0, (acc, inv) => acc + inv.collectedAmount);

      final debtParents = <String>{};
      for (final inv in unpaid) {
        final pid = inv.parentId ?? _childParent[inv.childId] ?? '';
        if (pid.isNotEmpty) debtParents.add(pid);
      }
      debtFamiliesCount.value = debtParents.length;
    });
  }

  /// Rebuild the per-child rows for [anchorMonth] from the cached invoices,
  /// then apply the active search + status filter.
  void _rebuildMonth() {
    final month = anchorMonth.value;
    final billed = <String, double>{};
    final collected = <String, double>{};
    final earliestDue = <String, int?>{};

    for (final inv in _branchInvoices) {
      final ms = inv.dueDate ?? inv.createdAt;
      if (ms == null) continue;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      if (d.year != month.year || d.month != month.month) continue;

      billed.update(inv.childId, (v) => v + inv.totalAmount,
          ifAbsent: () => inv.totalAmount);
      if (inv.collectedAmount > 0) {
        collected.update(inv.childId, (v) => v + inv.collectedAmount,
            ifAbsent: () => inv.collectedAmount);
      }
      if (inv.dueDate != null) {
        earliestDue.update(
            inv.childId, (v) => v == null || inv.dueDate! < v ? inv.dueDate : v,
            ifAbsent: () => inv.dueDate);
      }
    }

    final rows = billed.keys.map((childId) {
      final pid = _childParent[childId];
      return MonthlyPaymentRow(
        childId: childId,
        childName: _childNames[childId] ?? '',
        parentName: (pid != null ? _parentNames[pid] : null) ??
            'manager_finance_unknown_family'.tr,
        billed: billed[childId]!,
        collected: collected[childId] ?? 0,
        dueDate: earliestDue[childId],
      );
    }).toList()
      // Unpaid first (highest remaining), then settled — most urgent on top.
      ..sort((a, b) {
        if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
        return b.remaining.compareTo(a.remaining);
      });

    _allMonthRows
      ..clear()
      ..addAll(rows);
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    final filter = rowFilter.value;
    monthRows.assignAll(_allMonthRows.where((r) {
      final matchesFilter = filter == 'all' ||
          (filter == 'paid' && r.isPaid) ||
          (filter == 'due' && !r.isPaid);
      final matchesQuery = q.isEmpty ||
          r.childName.toLowerCase().contains(q) ||
          r.parentName.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }));
  }

  bool _isUnpaid(InvoiceModel inv) => inv.hasOutstanding;

  bool _isOverdue(InvoiceModel inv, int nowMs) =>
      inv.hasOutstanding &&
      (inv.status == 'overdue' ||
          (inv.dueDate != null && inv.dueDate! < nowMs));
}
