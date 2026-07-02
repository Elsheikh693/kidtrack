import '../../../../index/index_main.dart';

class OverdueController extends GetxController {
  // ── Data services ───────────────────────────────────────────────────────────
  final ExpenseParentService _expenseService = Get.find<ExpenseParentService>();
  final BaseService<PaymentCategoryModel> _catService =
      Get.find<BaseService<PaymentCategoryModel>>(tag: 'paymentCategories');

  /// All obligations loaded from Firebase.
  final RxList<Obligation> _all = <Obligation>[].obs;

  /// Filtered list shown in the UI.
  final RxList<Obligation> items = <Obligation>[].obs;

  /// Selected status filter (null = all).
  final Rxn<ObligationStatus> selectedFilter = Rxn<ObligationStatus>();

  /// Selected category filter (null = all categories).
  final RxnString selectedCategoryId = RxnString();

  /// Selected month to view (filters the list, not the totals).
  final Rx<DateTime> selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month).obs;

  /// Available payment categories (from PaymentCategoryModel).
  final RxList<ObligationCategory> categories = <ObligationCategory>[].obs;

  /// Loading state for the obligations list.
  final RxBool isLoading = false.obs;

  /// Saving state while creating an obligation.
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    loadData();
    ever(selectedFilter, (_) => _filter());
    ever(selectedCategoryId, (_) => _filter());
    ever(selectedMonth, (_) => _filter());
  }

  // ── Loading ─────────────────────────────────────────────────────────────────
  void _loadCategories() {
    _catService.getData(
      data: {},
      voidCallBack: (list) {
        categories.value = list
            .whereType<PaymentCategoryModel>()
            .where((c) => c.isActive)
            .map(
              (c) => ObligationCategory(
                id: c.key ?? '',
                name: c.name,
                colorValue: c.colorValue,
              ),
            )
            .toList();
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _expenseService.getAll(
      callBack: (list) {
        _all.value =
            list.whereType<ExpenseModel>().map(_toObligation).toList();
        _filter();
      },
    );
    isLoading.value = false;
  }

  Obligation _toObligation(ExpenseModel e) {
    final due = e.dueDate != null
        ? DateTime.fromMillisecondsSinceEpoch(e.dueDate!)
        : DateTime.now();
    return Obligation(
      id: e.key ?? '',
      party: e.party,
      item: e.item,
      categoryId: e.categoryId ?? '',
      categoryName: e.categoryName ?? '',
      amount: e.amount,
      dueDate: due,
      status: _statusOf(e, due),
    );
  }

  ObligationStatus _statusOf(ExpenseModel e, DateTime due) {
    if (e.isPaid) return ObligationStatus.paid;
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(due.year, due.month, due.day);
    return d1.isBefore(d0)
        ? ObligationStatus.overdue
        : ObligationStatus.upcoming;
  }

  // ── Totals (reactive via _all) ──────────────────────────────────────────────
  double get overdueTotal => _sum(ObligationStatus.overdue);
  double get upcomingTotal => _sum(ObligationStatus.upcoming);
  double get paidTotal => _sum(ObligationStatus.paid);
  int get overdueCount =>
      _all.where((o) => o.status == ObligationStatus.overdue).length;

  double _sum(ObligationStatus s) =>
      _all.where((o) => o.status == s).fold(0.0, (p, o) => p + o.amount);

  // ── Filtering ───────────────────────────────────────────────────────────────
  void setFilter(ObligationStatus? s) =>
      selectedFilter.value = (selectedFilter.value == s) ? null : s;

  void setCategory(String? id) =>
      selectedCategoryId.value = (selectedCategoryId.value == id) ? null : id;

  void setMonth(DateTime d) => selectedMonth.value = DateTime(d.year, d.month);

  void _filter() {
    final status = selectedFilter.value;
    final catId = selectedCategoryId.value;
    final m = selectedMonth.value;

    var list = [..._all]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    list = list
        .where((o) => o.dueDate.year == m.year && o.dueDate.month == m.month)
        .toList();
    if (status != null) list = list.where((o) => o.status == status).toList();
    if (catId != null) list = list.where((o) => o.categoryId == catId).toList();
    items.value = list;
  }

  // ── Navigation to finance management screens ────────────────────────────────
  void goInvoices() => Get.toNamed(invoicesView);
  void goPayments() => Get.toNamed(paymentsView);
  void goCategories() => Get.toNamed(paymentCategoriesView);

  // ── Create (full screen) ────────────────────────────────────────────────────
  void openCreate() {
    Get.to(
      () => OverdueCreateView(categories: categories, onSave: addObligation),
      fullscreenDialog: true,
    );
  }

  Future<void> addObligation({
    required String party,
    String? item,
    required ObligationCategory category,
    required double amount,
    required bool payNow,
    DateTime? dueDate,
  }) async {
    final session = SessionService();
    final now = DateTime.now();
    final due = payNow ? now : (dueDate ?? now);

    final expense = ExpenseModel(
      nurseryId: session.nurseryId ?? '',
      party: party.trim(),
      item: (item == null || item.trim().isEmpty) ? null : item.trim(),
      categoryId: category.id,
      categoryName: category.name,
      amount: amount,
      dueDate: due.millisecondsSinceEpoch,
      status: payNow ? 'paid' : 'pending',
      paidAt: payNow ? now.millisecondsSinceEpoch : null,
      paidBy: payNow ? session.currentUser?.displayName : null,
      createdAt: now.millisecondsSinceEpoch,
    );

    isSaving.value = true;
    await _expenseService.add(
      item: expense,
      callBack: (status) {
        if (status == ResponseStatus.success) {
          loadData();
        }
      },
    );
    isSaving.value = false;
  }
}
