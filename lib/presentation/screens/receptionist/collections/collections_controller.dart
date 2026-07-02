import '../../../../index/index_main.dart';

/// One unpaid (pending/overdue) invoice for the current month, resolved with
/// child + parent display info so the late-payers screen can render it and send
/// a reminder to the parent.
class LatePayer {
  final String invoiceId;
  final String childId;
  final String childName;
  final String? parentUserId;
  final String parentName;
  final double amount;
  final int? dueDate;
  final bool isOverdue;

  const LatePayer({
    required this.invoiceId,
    required this.childId,
    required this.childName,
    required this.parentUserId,
    required this.parentName,
    required this.amount,
    required this.dueDate,
    required this.isOverdue,
  });
}

/// Aggregates this month's parent fee collection for the receptionist's branch:
/// expected vs collected vs remaining, plus the list of late payers and the
/// ability to nudge them with a payment-reminder notification.
///
/// "This month" = invoices whose dueDate falls in the current calendar month.
class CollectionsController extends GetxController {
  // ── Selected month (by invoice dueDate). Defaults to the current month. ──────
  final selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;

  // ── Monthly totals (selected month, by dueDate) ─────────────────────────────
  final expectedTotal = 0.0.obs;
  final collectedTotal = 0.0.obs;
  final childrenCount = 0.obs;
  final familiesCount = 0.obs;

  // ── Late payers (unpaid invoices this month) ────────────────────────────────
  final latePayers = <LatePayer>[].obs;

  /// Raw invoice behind each late payer, so the receptionist can collect it.
  final _invoiceById = <String, InvoiceModel>{};

  final isLoading = true.obs;
  final sendingAll = false.obs;

  final _finance = FinanceService();

  double get remainingTotal =>
      (expectedTotal.value - collectedTotal.value).clamp(0, double.infinity);

  late final InvoiceParentService _invoiceSvc;
  late final ChildParentService _childSvc;
  late final GuardianParentService _guardianSvc;
  late final ParentChildParentService _parentChildSvc;
  final _notifSvc = NotificationSendService();
  final _session = SessionService();

  String get _branchId => _session.branchId ?? '';
  String get _nurseryId => _session.nurseryId ?? '';

  @override
  void onInit() {
    super.onInit();
    _invoiceSvc = Get.find<InvoiceParentService>();
    _childSvc = Get.find<ChildParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    _parentChildSvc = Get.find<ParentChildParentService>();
    loadData();
  }

  static bool _inMonth(int? dueDate, DateTime month) {
    if (dueDate == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(dueDate);
    return d.year == month.year && d.month == month.month;
  }

  /// Switches the viewed month and reloads. Months other than the current one
  /// are read-only history (every unpaid invoice there is already overdue).
  void setMonth(DateTime d) {
    selectedMonth.value = DateTime(d.year, d.month);
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    // Auto-generate this month's fee invoices from enrollment × package price,
    // so "expected" reflects who is enrolled — not just manually-added invoices.
    // No-op for history months and for children without a package.
    await MonthlyInvoiceService()
        .generateForMonth(month: selectedMonth.value, branchId: _branchId);

    // child -> (name, parentId) for this branch only
    final childName = <String, String>{};
    final childParent = <String, String?>{};
    await _childSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ChildModel>()) {
        if (c.branchId != _branchId || c.status != 'active') continue;
        if (c.key == null) continue;
        childName[c.key!] = c.fullName;
        childParent[c.key!] = c.parentId;
      }
    });

    // parent uid -> name
    final parentName = <String, String>{};
    await _guardianSvc.getAll(callBack: (list) {
      for (final p in list.whereType<ParentModel>()) {
        parentName[p.uid] = p.name;
      }
    });

    // childId -> primary parent uid (fallback when invoice/child lack parentId)
    final primaryParent = <String, String>{};
    await _parentChildSvc.getAll(callBack: (list) {
      for (final pc in list.whereType<ParentChildModel>()) {
        if (pc.isPrimary) primaryParent[pc.childId] = pc.parentId;
      }
    });

    await _invoiceSvc.getAll(callBack: (list) {
      final monthInvoices = list
          .whereType<InvoiceModel>()
          .where((inv) =>
              inv.status != 'cancelled' &&
              childName.containsKey(inv.childId) &&
              _inMonth(inv.dueDate, selectedMonth.value))
          .toList();

      double expected = 0;
      double collected = 0;
      final children = <String>{};
      final families = <String>{};
      final late = <LatePayer>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      _invoiceById.clear();

      for (final inv in monthInvoices) {
        expected += inv.totalAmount;
        children.add(inv.childId);

        final parentId = inv.parentId ??
            childParent[inv.childId] ??
            primaryParent[inv.childId];
        if (parentId != null) families.add(parentId);

        final paid = inv.status == 'paid';
        if (paid) {
          collected += inv.totalAmount;
        } else {
          if (inv.key != null) _invoiceById[inv.key!] = inv;
          late.add(LatePayer(
            invoiceId: inv.key ?? '',
            childId: inv.childId,
            childName:
                childName[inv.childId] ?? 'reception_unknown_child'.tr,
            parentUserId: parentId,
            parentName: (parentId != null ? parentName[parentId] : null) ??
                'reception_unknown_parent'.tr,
            amount: inv.totalAmount,
            dueDate: inv.dueDate,
            isOverdue: inv.status == 'overdue' ||
                (inv.dueDate != null && inv.dueDate! < now),
          ));
        }
      }

      late.sort((a, b) => (a.dueDate ?? 0).compareTo(b.dueDate ?? 0));

      expectedTotal.value = expected;
      collectedTotal.value = collected;
      childrenCount.value = children.length;
      familiesCount.value = families.length;
      latePayers.value = late;
    });

    isLoading.value = false;
  }

  /// Sends a payment reminder to one late payer's parent.
  Future<bool> remindOne(LatePayer payer) async {
    final uid = payer.parentUserId;
    if (uid == null || uid.isEmpty) {
      Get.snackbar('', 'collections_reminder_no_parent'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    final ok = await _notifSvc.sendToUser(uid, _reminderFor(payer));
    Get.snackbar(
      '',
      ok
          ? 'collections_reminder_sent'.tr
          : 'collections_reminder_failed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    return ok;
  }

  /// Records a fee payment for one late payer: marks the invoice paid and
  /// writes a payment record (same path the manager uses), then refreshes.
  Future<void> collect(LatePayer payer, String method) async {
    final invoice = _invoiceById[payer.invoiceId];
    if (invoice == null) return;

    Loader.show();
    final ok = await _finance.markAsPaid(
      invoice: invoice,
      paymentMethod: method,
    );
    Loader.dismiss();

    if (ok) {
      Loader.showSuccess('invoice_paid_success'.tr);
      await loadData();
    } else {
      Loader.showError('invoice_paid_error'.tr);
    }
  }

  /// Sends a reminder to every distinct parent in the late list (deduped).
  Future<void> remindAll() async {
    if (latePayers.isEmpty || sendingAll.value) return;
    sendingAll.value = true;

    final seen = <String>{};
    int sent = 0;
    for (final payer in latePayers) {
      final uid = payer.parentUserId;
      if (uid == null || uid.isEmpty || seen.contains(uid)) continue;
      seen.add(uid);
      final ok = await _notifSvc.sendToUser(uid, _reminderFor(payer));
      if (ok) sent++;
    }

    sendingAll.value = false;
    Get.snackbar(
      '',
      'collections_reminder_all_sent'.trParams({'count': '$sent'}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  NotificationModel _reminderFor(LatePayer payer) {
    final amount =
        '${payer.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}';
    return NotificationModel(
      userId: payer.parentUserId ?? '',
      nurseryId: _nurseryId,
      title: 'collections_reminder_title'.tr,
      body: 'collections_reminder_body'
          .trParams({'child': payer.childName, 'amount': amount}),
      type: 'finance',
      entityId: payer.invoiceId,
    );
  }
}
