import '../../../../index/index_main.dart';

/// Parent's read-only payment history for the active child.
///
/// Built entirely on [FinancialTransactionModel] via a Child→Transactions read
/// ([FinancialTransactionParentService.getByChild]) — the parent never touches
/// the branch-wide node. The service filters client-side for now; once the RTDB
/// `.indexOn: ["childId"]` rule is deployed it swaps to a server-side query
/// WITHOUT any change here, because this controller already asks by child.
class ParentInvoicesController extends GetxController {
  final _service = Get.find<FinancialTransactionParentService>();

  final RxList<FinancialTransactionModel> items =
      <FinancialTransactionModel>[].obs;
  final RxBool isLoading = true.obs;

  String get _childId => Get.find<ActiveChildService>().childId.value;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _childWorker = ever<String>(
      Get.find<ActiveChildService>().childId,
      (_) => loadData(),
    );
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }

  /// Total amount this child has paid across all recorded collections.
  double get totalPaid => items.fold(0, (total, t) => total + t.amount);

  /// Number of recorded payments.
  int get count => items.length;

  Future<void> loadData() async {
    isLoading.value = true;
    final childId = _childId;
    if (childId.isEmpty) {
      items.clear();
      isLoading.value = false;
      return;
    }
    // Already sorted newest-first by the service.
    items.value = await _service.getByChild(childId);
    isLoading.value = false;
  }
}
