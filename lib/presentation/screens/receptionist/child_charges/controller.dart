import '../../../../index/index_main.dart';
import 'widgets/child_charge_sheet.dart';
import 'widgets/charge_payment_sheet.dart';

/// Reception "daily expenses" screen — CRUD over ad-hoc charges a receptionist
/// adds for a specific child's guardian (pampers, a book, medicine…). Each
/// charge is stored as a `source: 'daily_expense'` invoice, so it flows into the
/// collection tab and the guardian's "needs attention" screen, and on creation
/// it also messages + notifies the parent (see [ChildChargeParentService]).
class ChildChargesController extends GetxController {
  late final ChildChargeParentService _chargeSvc;
  late final ChildParentService _childSvc;
  late final ParentChildParentService _linkSvc;
  late final GuardianParentService _guardianSvc;

  final _session = SessionService();

  final RxList<InvoiceModel> charges = <InvoiceModel>[].obs;
  final RxList<InvoiceModel> filtered = <InvoiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  final _childById = <String, ChildModel>{};
  final _parentNames = <String, String>{};
  final _parentIds = <String, String>{};

  late final Worker _searchWorker;

  String get _branchId => _session.branchId ?? '';

  /// Active children in scope, for the add-sheet picker.
  List<ChildModel> get pickableChildren {
    final list = _childById.values.toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    _chargeSvc = Get.find<ChildChargeParentService>();
    _childSvc = Get.find<ChildParentService>();
    _linkSvc = Get.find<ParentChildParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    load();
    _searchWorker = debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _loadChildrenAndParents();
    charges.value = await _chargeSvc.getCharges();
    _filter();
    isLoading.value = false;
  }

  // ── Lookups exposed to the widgets ────────────────────────────────────────
  ChildModel? childOf(String childId) => _childById[childId];
  String childName(String childId) => _childById[childId]?.fullName ?? '';
  String? childImage(String childId) => _childById[childId]?.profileImage;

  bool canModify(InvoiceModel c) => !c.isFullyPaid && c.paidAmount <= 0.5;

  // ── CRUD entry points ─────────────────────────────────────────────────────
  void openAdd() => _openSheet(null);
  void openEdit(InvoiceModel charge) => _openSheet(charge);

  /// Opens the collect-payment sheet for [charge].
  void openCollect(InvoiceModel charge) {
    Get.bottomSheet(
      ChargePaymentSheet(controller: this, charge: charge),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  /// Settles [amount] against [charge] via the shared finance pipeline — this
  /// updates the invoice, writes a payment ledger row AND a revenue-log entry
  /// (so the collection shows up in the finance reports).
  Future<void> recordPayment({
    required InvoiceModel charge,
    required double amount,
    required String method,
  }) async {
    final child = childOf(charge.childId);
    Loader.show();
    final ok = await FinanceService().recordPayment(
      invoice: charge,
      amount: amount,
      paymentMethod: method,
      branchId: child?.branchId,
      childName: child?.fullName,
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('daily_expense_paid'.tr);
      Get.back();
      load();
      _refreshFinanceDashboards();
    } else {
      Loader.showError('daily_expense_error'.tr);
    }
  }

  /// The owner/manager finance dashboard caches its transactions and only
  /// refetches on first open or pull-to-refresh. Nudge any live instance to
  /// reload so this fresh collection shows up in الماليات immediately.
  void _refreshFinanceDashboards() {
    for (final tag in const ['manager_finance', 'owner_finance']) {
      if (Get.isRegistered<FinanceDashboardController>(tag: tag)) {
        Get.find<FinanceDashboardController>(tag: tag).reload();
      }
    }
  }

  void _openSheet(InvoiceModel? charge) {
    Get.bottomSheet(
      ChildChargeSheet(controller: this, existing: charge),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  /// Creates a charge for [child] and fires the parent chat/notification.
  Future<void> submitAdd({
    required ChildModel child,
    required double amount,
    required String reason,
  }) async {
    Loader.show();
    await _chargeSvc.addCharge(
      child: child,
      parentId: _parentIds[child.key] ?? child.parentId ?? '',
      parentName: _parentNames[child.key] ?? '',
      amount: amount,
      reason: reason,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('daily_expense_saved'.tr);
          Get.back();
          load();
        } else {
          Loader.showError('daily_expense_error'.tr);
        }
      },
    );
  }

  /// Edits an unpaid charge — amount and reason only.
  Future<void> submitEdit({
    required InvoiceModel item,
    required double amount,
    required String reason,
  }) async {
    Loader.show();
    final updated = item.copyWith(
      amount: amount,
      totalAmount: amount,
      title: reason,
    );
    await _chargeSvc.updateCharge(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('daily_expense_updated'.tr);
          Get.back();
          load();
        } else {
          Loader.showError('daily_expense_error'.tr);
        }
      },
    );
  }

  Future<void> delete(InvoiceModel charge) async {
    Loader.show();
    await _chargeSvc.deleteCharge(
      id: charge.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('daily_expense_deleted'.tr);
          load();
        } else {
          Loader.showError('daily_expense_error'.tr);
        }
      },
    );
  }

  // ── Internals ─────────────────────────────────────────────────────────────
  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(charges);
      return;
    }
    filtered.assignAll(charges.where((c) {
      final name = childName(c.childId).toLowerCase();
      final reason = (c.title ?? '').toLowerCase();
      return name.contains(q) || reason.contains(q);
    }));
  }

  bool _inScope(ChildModel c) {
    if (c.status != 'active') return false;
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final b = _branchId;
    if (b.isNotEmpty && c.branchId != b) return false;
    return _session.seesShift(c.shift);
  }

  Future<void> _loadChildrenAndParents() async {
    _childById.clear();
    await _childSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ChildModel>().where(_inScope)) {
        if (c.key != null) _childById[c.key!] = c;
      }
    });

    final nameByUid = <String, String>{};
    await _guardianSvc.getAll(callBack: (list) {
      for (final p in list.whereType<ParentModel>()) {
        nameByUid[p.uid] = p.name;
      }
    });
    await _linkSvc.getAll(callBack: (list) {
      final names = <String, String>{};
      final ids = <String, String>{};
      for (final link in list.whereType<ParentChildModel>()) {
        final name = nameByUid[link.parentId];
        if (name == null) continue;
        if (link.isPrimary || !names.containsKey(link.childId)) {
          names[link.childId] = name;
          ids[link.childId] = link.parentId;
        }
      }
      _parentNames
        ..clear()
        ..addAll(names);
      _parentIds
        ..clear()
        ..addAll(ids);
    });
  }
}
