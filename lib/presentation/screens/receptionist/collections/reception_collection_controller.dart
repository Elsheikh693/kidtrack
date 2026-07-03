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
  late final FeeCategoryParentService _categoryService;
  late final FinancialTransactionParentService _txService;

  final _session = SessionService();

  // ─── Directory (branch-scoped) ────────────────────────────────────────────
  final RxList<ChildModel> children = <ChildModel>[].obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxMap<String, String> parentNames = <String, String>{}.obs;

  // ─── Fee categories the receptionist collects against ─────────────────────
  final RxList<FeeCategoryModel> categories = <FeeCategoryModel>[].obs;

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
    _categoryService = Get.find<FeeCategoryParentService>();
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
    await Future.wait([_loadChildren(), _loadLookups(), _loadCategories()]);
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

  Future<void> _loadCategories() async {
    categories.value = await _categoryService.getActive();
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

  Future<bool> saveCollection({
    required FeeCategoryModel category,
    required double amount,
    String? notes,
  }) async {
    final child = selectedChild.value;
    if (child == null || child.key == null || amount <= 0) {
      Loader.showError('payment_fill_required'.tr);
      return false;
    }

    final tx = FinancialTransactionModel(
      nurseryId: _session.nurseryId ?? ApiConstants.nurseryId,
      branchId: child.branchId,
      childId: child.key!,
      childName: child.fullName,
      categoryId: category.key ?? '',
      categoryName: category.name,
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
      Loader.showSuccess('collection_saved'.tr);
      await _loadHistory(child.key!);
    } else {
      Loader.showError('collection_save_failed'.tr);
    }
    return ok;
  }
}
