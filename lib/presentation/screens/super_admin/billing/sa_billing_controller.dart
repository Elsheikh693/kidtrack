import '../../../../index/index_main.dart';
import '../../billing/billing_utils.dart';

/// One nursery's row in the SuperAdmin billing list for the selected month.
class SaBillingRow {
  final NurseryModel nursery;
  final int childCount;
  final double amount;
  final bool paid;

  const SaBillingRow({
    required this.nursery,
    required this.childCount,
    required this.amount,
    required this.paid,
  });
}

/// SuperAdmin: subscription billing across ALL nurseries for a chosen month.
/// Child count / amount are projected from the registry `childrenCount` for the
/// list (cheap); the exact per-branch split is recomputed only when a nursery is
/// opened / collected.
class SaBillingController extends GetxController {
  final NurseryParentService _nurseries = Get.find<NurseryParentService>();
  final PlatformBillingService _billing = Get.find<PlatformBillingService>();

  final Rx<int> selectedMonth = BillingMonth.current().obs;
  final RxList<SaBillingRow> rows = <SaBillingRow>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  double get totalBilled => rows.fold(0, (s, r) => s + r.amount);
  double get totalCollected =>
      rows.where((r) => r.paid).fold(0, (s, r) => s + r.amount);
  double get totalOutstanding =>
      rows.where((r) => !r.paid).fold(0, (s, r) => s + r.amount);
  int get paidCount => rows.where((r) => r.paid).length;

  Future<void> load() async {
    isLoading.value = true;
    final month = selectedMonth.value;

    List<NurseryModel> nurseries = const [];
    await _nurseries.getAll(callBack: (list) {
      nurseries = list.whereType<NurseryModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });

    final bills = await _billing.getMonthBills(month);

    rows.value = nurseries.map((n) {
      final bill = bills[n.key];
      if (bill != null) {
        return SaBillingRow(
          nursery: n,
          childCount: bill.totalChildCount,
          amount: bill.totalAmount,
          paid: bill.isPaid,
        );
      }
      final count = n.childrenCount ?? 0;
      return SaBillingRow(
        nursery: n,
        childCount: count,
        amount: count * kPlatformPricePerChild,
        paid: false,
      );
    }).toList();

    isLoading.value = false;
  }

  void setMonth(int month) {
    if (month == selectedMonth.value) return;
    selectedMonth.value = month;
    load();
  }

  void openDetail(NurseryModel nursery) {
    Get.toNamed(
      platformBillingDetailView,
      arguments: {'nursery': nursery, 'month': selectedMonth.value},
    )?.then((_) => load());
  }
}
