import '../../../index/index_main.dart';
import 'billing_utils.dart';

/// Owner / manager view of their OWN nursery's platform subscription bill for a
/// chosen month. Read-only — only the SuperAdmin collects. When a month has a
/// stored (collected) record it is shown as-is; otherwise the bill is projected
/// live from the current active child count.
class MySubscriptionController extends GetxController {
  final PlatformBillingService _service = Get.find<PlatformBillingService>();
  final PlatformPaymentService _paymentService =
      Get.find<PlatformPaymentService>();

  final String _nurseryId = SessionService().nurseryId ?? '';

  final Rx<int> selectedMonth = BillingMonth.current().obs;
  final Rxn<PlatformBillModel> bill = Rxn<PlatformBillModel>();
  final Rxn<PlatformPaymentInfoModel> paymentInfo =
      Rxn<PlatformPaymentInfoModel>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    _loadPaymentInfo();
  }

  /// The platform's collection accounts are month-independent, so load once.
  Future<void> _loadPaymentInfo() async {
    paymentInfo.value = await _paymentService.get();
  }

  /// Copy an InstaPay / wallet number to the clipboard with a confirmation.
  void copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    Loader.showSuccess('pay_copied'.tr);
  }

  /// Open the InstaPay transfer link, normalising a bare URL to https.
  Future<void> openPaymentLink(String url) async {
    var normalized = url.trim();
    if (!normalized.startsWith('http')) normalized = 'https://$normalized';
    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('pay_open_error'.tr);
    }
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
