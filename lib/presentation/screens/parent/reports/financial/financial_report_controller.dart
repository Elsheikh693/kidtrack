import '../../../../../index/index_main.dart';

/// A category and the total collected under it for the child.
class FinancialCategoryTotal {
  final String name;
  final double amount;
  const FinancialCategoryTotal({required this.name, required this.amount});
}

class FinancialReportController extends GetxController {
  late final FinancialTransactionParentService _txSvc;
  late final NurseryParentService _nurserySvc;
  late final ActiveChildService _activeChild;

  final isLoading = true.obs;
  final items = <FinancialTransactionModel>[].obs;
  final totalPaid = 0.0.obs;
  final thisMonthTotal = 0.0.obs;
  final paymentsCount = 0.obs;
  final categories = <FinancialCategoryTotal>[].obs;
  final isEmpty = false.obs;

  String childName = '';
  String nurseryName = '';
  String? nurseryLogo;

  @override
  void onInit() {
    super.onInit();
    _txSvc = Get.find<FinancialTransactionParentService>();
    _nurserySvc = Get.find<NurseryParentService>();
    _activeChild = Get.find<ActiveChildService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    childName = _activeChild.childName.value;
    final childId = _activeChild.childId.value;

    // Nursery details and the child's transactions are independent — fetch both
    // at once instead of one after the other.
    final nurseryF = _loadNursery();
    final txF = childId.isEmpty
        ? Future.value(<FinancialTransactionModel>[])
        : _txSvc.getByChild(childId);

    await nurseryF;
    final list = await txF;
    items.value = list;
    _recompute(list);

    isLoading.value = false;
  }

  Future<void> _loadNursery() async {
    final sessionNurseryId = SessionService().nurseryId ?? '';
    await _nurserySvc.getAll(
      callBack: (list) {
        final nurseries = list.whereType<NurseryModel>();
        if (nurseries.isEmpty) return;
        final n = nurseries.firstWhere(
          (item) => item.key == sessionNurseryId,
          orElse: () => nurseries.first,
        );
        nurseryName = n.name;
        nurseryLogo = n.logo;
      },
    );
  }

  void _recompute(List<FinancialTransactionModel> list) {
    isEmpty.value = list.isEmpty;
    paymentsCount.value = list.length;
    totalPaid.value = list.fold(0.0, (sum, t) => sum + t.amount);

    final now = DateTime.now();
    thisMonthTotal.value = list.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      return d.year == now.year && d.month == now.month;
    }).fold(0.0, (sum, t) => sum + t.amount);

    final byCategory = <String, double>{};
    for (final t in list) {
      final name = t.categoryName.trim().isEmpty
          ? 'report_financial_other'.tr
          : t.categoryName.trim();
      byCategory[name] = (byCategory[name] ?? 0) + t.amount;
    }
    categories.value = (byCategory.entries
            .map((e) => FinancialCategoryTotal(name: e.key, amount: e.value))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount)));
  }

  static String formatDate(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${d.day}/${d.month}/${d.year}';
  }
}
