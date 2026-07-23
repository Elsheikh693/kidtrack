import '../../../../index/index_main.dart';

/// Drives the receptionist "الماليات" tab — a child-centric collections screen.
/// Each in-scope child is listed with their outstanding balance (aggregated
/// from their unpaid/partial [InvoiceModel]s); the receptionist collects the
/// full remaining or a partial amount, picks a method (cash/InstaPay/wallet),
/// and the payment is waterfalled across that child's open invoices while a
/// [FinancialTransactionModel] revenue-log entry records the collected total.
class ReceptionCollectionController extends GetxController {
  late final ChildParentService _childService;
  late final ClassroomParentService _classroomService;
  late final ParentChildParentService _linkService;
  late final GuardianParentService _guardianService;
  late final FinancialTransactionParentService _txService;

  final _session = SessionService();
  final _finance = FinanceService();

  // ─── Directory (branch-scoped) ────────────────────────────────────────────
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxMap<String, String> parentNames = <String, String>{}.obs;

  // ─── Per-child outstanding (المستحق) ──────────────────────────────────────
  /// childId -> total remaining across all that child's unpaid/partial invoices.
  final RxMap<String, double> outstandingByChild = <String, double>{}.obs;

  /// childId -> that child's open invoices (oldest-first), the collection targets.
  final Map<String, List<InvoiceModel>> _openInvoices = {};

  /// childId -> a guardian-uploaded transfer screenshot awaiting confirmation.
  /// Drives the "إثبات تحويل" badge on the child card and the proof preview in
  /// the collect sheet, so reception knows who to confirm.
  final RxMap<String, String> proofUrlByChild = <String, String>{}.obs;

  // ─── Selection + that child's history ─────────────────────────────────────
  final Rxn<ChildModel> selectedChild = Rxn<ChildModel>();
  final RxList<FinancialTransactionModel> history =
      <FinancialTransactionModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxString searchQuery = ''.obs;
  final searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _childService = Get.find<ChildParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _linkService = Get.find<ParentChildParentService>();
    _guardianService = Get.find<GuardianParentService>();
    _txService = Get.find<FinancialTransactionParentService>();
    loadData();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void onSearch(String q) => searchQuery.value = q;

  List<ChildModel> get filteredChildren {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return children
        .where((c) => c.fullName.toLowerCase().contains(q))
        .toList();
  }

  String classroomName(String? id) => (id == null || classroomNames[id] == null)
      ? 'child_classroom_none'.tr
      : classroomNames[id]!;

  String parentName(String? childId) =>
      childId == null ? '' : (parentNames[childId] ?? '');

  // ─── Load directory + categories ──────────────────────────────────────────

  Future<void> loadData() async {
    isLoading.value = true;
    // The directory + name lookups don't depend on invoices — load them in
    // parallel with generating/reading this month's invoices, which returns the
    // list so we bucket outstanding WITHOUT a second read.
    final results = await Future.wait([
      _loadChildren(),
      _loadLookups(),
      MonthlyInvoiceService().generateForMonth(
        month: DateTime(DateTime.now().year, DateTime.now().month),
        branchId: _session.branchId,
      ),
    ]);
    _loadOutstanding(results[2] as List<InvoiceModel>);
    isLoading.value = false;
  }

  Future<void> _loadChildren() async {
    await _childService.getAll(
      callBack: (list) {
        children.value = list
            .whereType<ChildModel>()
            .where(_inScope)
            .toList()
          ..sort((a, b) => a.fullName.compareTo(b.fullName));
      },
    );
  }

  /// Receptionist only sees their own branch + shift.
  bool _inScope(ChildModel c) {
    final bId = _session.branchId;
    if (bId != null && bId.isNotEmpty && c.branchId != bId) return false;
    return _session.seesShift(c.shift);
  }

  // ─── Outstanding (المستحق) ────────────────────────────────────────────────

  /// Buckets every in-scope child's remaining balance from their open invoices
  /// (unpaid + partially-paid). Keeps the raw open invoices per child so a
  /// collection can be waterfalled across them oldest-first.
  void _loadOutstanding(List<InvoiceModel> invoices) {
    final scoped = children.map((c) => c.key).whereType<String>().toSet();
    final byChild = <String, double>{};
    final proofs = <String, String>{};
    _openInvoices.clear();
    for (final inv in invoices) {
      if (!scoped.contains(inv.childId) || !inv.hasOutstanding) continue;
      byChild[inv.childId] = (byChild[inv.childId] ?? 0) + inv.remaining;
      (_openInvoices[inv.childId] ??= []).add(inv);
      if (inv.hasPendingProof) proofs[inv.childId] = inv.proofUrl!;
    }
    for (final l in _openInvoices.values) {
      l.sort((a, b) => (a.dueDate ?? a.createdAt ?? 0)
          .compareTo(b.dueDate ?? b.createdAt ?? 0));
    }
    outstandingByChild.value = byChild;
    proofUrlByChild.value = proofs;
  }

  double outstandingFor(String? childId) =>
      childId == null ? 0 : (outstandingByChild[childId] ?? 0);

  /// The transfer screenshot a guardian uploaded for [childId], if one is
  /// awaiting reception confirmation.
  String? proofFor(String? childId) =>
      childId == null ? null : proofUrlByChild[childId];

  double get totalOutstanding =>
      outstandingByChild.values.fold(0.0, (a, b) => a + b);

  /// Directory order: children with an uploaded transfer proof first (they need
  /// confirming), then whoever owes the most, then settled ones alphabetically.
  List<ChildModel> get orderedChildren {
    final list = children.toList();
    list.sort((a, b) {
      final pa = proofFor(a.key) != null;
      final pb = proofFor(b.key) != null;
      if (pa != pb) return pa ? -1 : 1;
      final da = outstandingFor(a.key);
      final db = outstandingFor(b.key);
      if (da != db) return db.compareTo(da);
      return a.fullName.compareTo(b.fullName);
    });
    return list;
  }

  Future<void> _loadLookups() async {
    // Classrooms are independent; guardians must land before the links resolve
    // names. Run the classroom read in parallel with the guardian→links chain.
    final parentById = <String, String>{};
    final links = <ParentChildModel>[];
    await Future.wait([
      _classroomService.getAll(
        callBack: (list) {
          final map = <String, String>{};
          for (final c in list.whereType<ClassroomModel>()) {
            if (c.key != null) map[c.key!] = c.name;
          }
          classroomNames.value = map;
        },
      ),
      Future(() async {
        await Future.wait([
          _guardianService.getAll(
            callBack: (list) {
              for (final p in list.whereType<ParentModel>()) {
                parentById[p.uid] = p.name;
              }
            },
          ),
          _linkService.getAll(
            callBack: (list) => links.addAll(list.whereType<ParentChildModel>()),
          ),
        ]);
      }),
    ]);

    final map = <String, String>{};
    for (final link in links) {
      final name = parentById[link.parentId];
      if (name == null) continue;
      if (link.isPrimary || !map.containsKey(link.childId)) {
        map[link.childId] = name;
      }
    }
    parentNames.value = map;
  }

  // ─── Child selection + history ────────────────────────────────────────────

  Future<void> selectChild(ChildModel child) async {
    selectedChild.value = child;
    searchQuery.value = '';
    searchCtrl.clear();
    await _loadHistory(child.key ?? '');
  }

  void clearSelection() {
    selectedChild.value = null;
    history.clear();
  }

  Future<void> _loadHistory(String childId) async {
    if (childId.isEmpty) return;
    isLoadingHistory.value = true;
    history.value = await _txService.getByChild(childId);
    isLoadingHistory.value = false;
  }

  double get childTotalPaid =>
      history.fold(0, (total, t) => total + t.amount);

  // ─── Collect dues (full / partial + method) ───────────────────────────────

  /// Collects [amount] from [child] against their outstanding invoices, spread
  /// oldest-first (waterfall): each invoice is settled in turn until the amount
  /// runs out — the last one may be left "partial" with a remaining balance.
  /// [method] is one of 'cash' | 'instapay' | 'wallet'. Writes a revenue-log
  /// entry for the total actually applied, then refreshes balances + history.
  Future<bool> collectDues({
    required ChildModel child,
    required double amount,
    required String method,
  }) async {
    final childId = child.key;
    if (childId == null || amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return false;
    }

    final invoices = List<InvoiceModel>.from(_openInvoices[childId] ?? const []);
    Loader.show();

    var remaining = amount;
    // Mirror the post-payment state locally so we can update the UI instantly
    // without a server re-read (which can lag right after a write).
    final stillOpen = <InvoiceModel>[];
    for (final inv in invoices) {
      if (remaining <= 0.5) {
        stillOpen.add(inv);
        continue;
      }
      final pay = remaining >= inv.remaining ? inv.remaining : remaining;
      // recordPayment writes the invoice + payment + revenue-log transaction;
      // passing the child avoids a lookup per invoice in the waterfall.
      final ok = await _finance.recordPayment(
        invoice: inv,
        amount: pay,
        paymentMethod: method,
        branchId: child.branchId,
        childName: child.fullName,
      );
      if (!ok) {
        stillOpen.add(inv);
        continue;
      }
      remaining -= pay;
      final newPaid =
          (inv.collectedAmount + pay).clamp(0, inv.totalAmount).toDouble();
      final updated = inv.copyWith(
        paidAmount: newPaid,
        status: newPaid >= inv.totalAmount - 0.5 ? 'paid' : 'partial',
      );
      if (updated.hasOutstanding) stillOpen.add(updated);
    }

    final applied = amount - remaining;
    Loader.dismiss();

    if (applied > 0.5) {
      Loader.showSuccess('collection_saved'.tr);
      // Instant, optimistic UI update from the locally-mirrored state.
      _openInvoices[childId] = stillOpen;
      final newTotal = stillOpen.fold<double>(0, (a, i) => a + i.remaining);
      final balances = Map<String, double>.from(outstandingByChild);
      if (newTotal <= 0.5) {
        balances.remove(childId);
      } else {
        balances[childId] = newTotal;
      }
      outstandingByChild.value = balances;
      // Drop the pending-proof badge once no open invoice still carries one.
      if (stillOpen.every((i) => !i.hasPendingProof)) {
        final proofs = Map<String, String>.from(proofUrlByChild)..remove(childId);
        proofUrlByChild.value = proofs;
      }
      if (selectedChild.value?.key == childId) await _loadHistory(childId);
      // Refresh the month summary + unpaid card if they're live on screen.
      if (Get.isRegistered<CollectionsController>()) {
        Get.find<CollectionsController>().loadData();
      }
      if (Get.isRegistered<UnpaidSubscriptionController>()) {
        Get.find<UnpaidSubscriptionController>().load();
      }
      return true;
    }
    Loader.showError('collection_save_failed'.tr);
    return false;
  }
}
