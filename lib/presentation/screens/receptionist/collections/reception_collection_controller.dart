import '../../../../index/index_main.dart';

/// Drives the receptionist "الماليات" tab — a pure cash-collection log built
/// only on [FeeCategoryModel] + [FinancialTransactionModel] (no old Invoice
/// system). The receptionist searches a child, sees what that child already
/// paid, and records new cash.
class ReceptionCollectionController extends GetxController {
  late final ChildParentService _childService;
  late final ClassroomParentService _classroomService;
  late final ParentChildParentService _linkService;
  late final GuardianParentService _guardianService;
  late final PackageParentService _packageService;
  late final FinancialTransactionParentService _txService;
  late final InvoiceParentService _invoiceService;

  final _session = SessionService();
  final _finance = FinanceService();

  // ─── Directory (branch-scoped) ────────────────────────────────────────────
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxMap<String, String> parentNames = <String, String>{}.obs;

  // ─── Packages the receptionist collects against (the branch's price list) ──
  final RxList<PackageModel> packages = <PackageModel>[].obs;

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
    _packageService = Get.find<PackageParentService>();
    _txService = Get.find<FinancialTransactionParentService>();
    _invoiceService = Get.find<InvoiceParentService>();
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
    await Future.wait([_loadChildren(), _loadLookups(), _loadPackages()]);
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

  Future<void> _loadLookups() async {
    await _classroomService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ClassroomModel>()) {
          if (c.key != null) map[c.key!] = c.name;
        }
        classroomNames.value = map;
      },
    );
    final parentById = <String, String>{};
    await _guardianService.getAll(
      callBack: (list) {
        for (final p in list.whereType<ParentModel>()) {
          parentById[p.uid] = p.name;
        }
      },
    );
    await _linkService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final link in list.whereType<ParentChildModel>()) {
          final name = parentById[link.parentId];
          if (name == null) continue;
          if (link.isPrimary || !map.containsKey(link.childId)) {
            map[link.childId] = name;
          }
        }
        parentNames.value = map;
      },
    );
  }

  /// Active packages this receptionist can collect against: their own branch's
  /// packages plus any network-wide package (no branch pinned). These are the
  /// exact price-list entries the owner/manager defined in "الباقات".
  Future<void> _loadPackages() async {
    final out = <PackageModel>[];
    await _packageService.getAll(
      callBack: (list) => out.addAll(list.whereType<PackageModel>()),
    );
    final bId = _session.branchId;
    packages.value = out.where((p) => p.isActive && _packageInScope(p, bId)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  bool _packageInScope(PackageModel p, String? branchId) {
    if (branchId == null || branchId.isEmpty) return true;
    return p.branchId == null || p.branchId!.isEmpty || p.branchId == branchId;
  }

  /// The branch's monthly subscription package (first active monthly package in
  /// scope), or null if none is set up. Drives the one-tap "renew" shortcut on
  /// the directory list.
  PackageModel? get monthlyPackage {
    for (final p in packages) {
      if (p.duration == 'monthly') return p;
    }
    return null;
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

  // ─── Save a collection ────────────────────────────────────────────────────

  /// Records a collection for [child] (or the currently selected child when the
  /// quick directory shortcut doesn't select one). Keeping [child] explicit lets
  /// the reception directory renew a child inline without leaving the list.
  Future<bool> saveCollection({
    required PackageModel package,
    required double amount,
    String? notes,
    ChildModel? child,
  }) async {
    final target = child ?? selectedChild.value;
    if (target == null || target.key == null || amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return false;
    }

    final tx = FinancialTransactionModel(
      key: const Uuid().v4(),
      nurseryId: _session.nurseryId ?? ApiConstants.nurseryId,
      branchId: target.branchId,
      childId: target.key!,
      childName: target.fullName,
      categoryId: package.key ?? '',
      categoryName: package.name,
      amount: amount,
      date: DateTime.now().millisecondsSinceEpoch,
      collectedBy: _session.userId,
      collectedByName: _session.currentUser?.name,
      notes: (notes != null && notes.trim().isNotEmpty) ? notes.trim() : null,
    );

    Loader.show();
    var ok = false;
    await _txService.add(
      item: tx,
      callBack: (status) => ok = status == ResponseStatus.success,
      silent: true,
    );
    Loader.dismiss();

    if (ok) {
      // Recording a monthly-subscription collection applies this cash against
      // that child's current-month invoice. A full amount settles it ("paid");
      // a smaller amount leaves it "partial" with the remaining balance, so the
      // guardian's "محتاج انتباهك" and المطلوب/المحصّل stay accurate.
      if (package.duration == 'monthly') {
        await _applyMonthlyPayment(target, amount);
      }
      Loader.showSuccess('collection_saved'.tr);
      // Only reload the open history panel if we collected for the child that's
      // currently expanded on screen.
      if (selectedChild.value?.key == target.key) {
        await _loadHistory(target.key!);
      }
      // Live-link: a fresh collection may clear a child off the "unpaid this
      // month" list, so refresh that shared controller right away instead of
      // waiting for an app restart.
      if (Get.isRegistered<UnpaidSubscriptionController>()) {
        Get.find<UnpaidSubscriptionController>().load();
      }
    } else {
      Loader.showError('collection_save_failed'.tr);
    }
    return ok;
  }

  /// Applies [amount] of collected cash against the child's current-month
  /// monthly invoice (`month_{childId}_{YYYYMM}`), if one exists and isn't
  /// already fully paid. Partial amounts leave the invoice "partial" with the
  /// remaining balance; a full amount settles it. This is the bridge between the
  /// cash-collection log and the invoice-based dues the guardian app reads.
  /// No-op when the child has no invoice this month (nothing is owed).
  Future<void> _applyMonthlyPayment(ChildModel child, double amount) async {
    final childId = child.key;
    if (childId == null) return;
    final key = MonthlyInvoiceService.monthlyKey(childId, DateTime.now());

    InvoiceModel? invoice;
    await _invoiceService.getAll(
      callBack: (list) {
        for (final inv in list.whereType<InvoiceModel>()) {
          if (inv.key == key) {
            invoice = inv;
            break;
          }
        }
      },
    );

    final inv = invoice;
    if (inv == null || inv.isFullyPaid) return;
    await _finance.recordPayment(
      invoice: inv,
      amount: amount,
      paymentMethod: 'cash',
    );
  }
}
