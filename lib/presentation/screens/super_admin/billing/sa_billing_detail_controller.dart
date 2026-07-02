import '../../../../index/index_main.dart';
import '../../billing/billing_utils.dart';

/// SuperAdmin: one nursery's platform bill for a fixed month, with the collect /
/// undo actions. The month is passed in and does not change here.
class SaBillingDetailController extends GetxController {
  final PlatformBillingService _service = Get.find<PlatformBillingService>();

  late final NurseryModel nursery;
  late final int month;

  final Rxn<PlatformBillModel> bill = Rxn<PlatformBillModel>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? const {};
    nursery = args['nursery'] as NurseryModel;
    month = args['month'] as int? ?? BillingMonth.current();
    load();
  }

  bool get isPaid => bill.value?.isPaid ?? false;

  Future<void> load() async {
    isLoading.value = true;
    final stored = await _service.getBill(nursery.key ?? '', month);
    bill.value = stored ?? await _service.projectBill(nursery.key ?? '', month);
    isLoading.value = false;
  }

  /// Collect: recompute a fresh breakdown, snapshot it and mark the month paid.
  Future<void> collect() async {
    if (isSaving.value) return;
    isSaving.value = true;
    final nurseryId = nursery.key ?? '';
    final branches = await _service.computeBranchBreakdown(nurseryId, month);
    final totalChildren = branches.fold<int>(0, (s, b) => s + b.childCount);
    await _service.markPaid(
      nurseryId: nurseryId,
      month: month,
      branches: branches,
      totalChildCount: totalChildren,
      totalAmount: totalChildren * kPlatformPricePerChild,
    );
    await load();
    isSaving.value = false;
  }

  /// Undo a previous collection for this month.
  Future<void> undo() async {
    if (isSaving.value) return;
    isSaving.value = true;
    await _service.markUnpaid(nursery.key ?? '', month);
    await load();
    isSaving.value = false;
  }
}
