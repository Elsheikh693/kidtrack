import '../../../index/index_main.dart';
import 'billing_utils.dart';

/// Owner / manager view of their OWN nursery's platform subscription bill for a
/// chosen month. Read-only — only the SuperAdmin collects. When a month has a
/// stored (collected) record it is shown as-is; otherwise the bill is projected
/// live from the current active child count.
class MySubscriptionController extends GetxController {
  final PlatformBillingService _service = Get.find<PlatformBillingService>();

  final String _nurseryId = SessionService().nurseryId ?? '';

  final Rx<int> selectedMonth = BillingMonth.current().obs;
  final Rxn<PlatformBillModel> bill = Rxn<PlatformBillModel>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (_nurseryId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    final month = selectedMonth.value;
    final stored = await _service.getBill(_nurseryId, month);
    bill.value = stored ?? await _service.projectBill(_nurseryId, month);
    isLoading.value = false;
  }

  void setMonth(int month) {
    if (month == selectedMonth.value) return;
    selectedMonth.value = month;
    load();
  }
}
