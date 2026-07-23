import '../../../../index/index_main.dart';
import 'widgets/payment_account_sheet.dart';

/// Owner/manager editor for the nursery's own collection accounts (InstaPay /
/// e-wallet). A simple CRUD list — the add/edit form lives in
/// [PaymentAccountSheet]; this controller loads, reloads and deletes.
class NurseryPaymentAccountsController extends GetxController {
  late final PaymentAccountParentService _service;

  final RxList<PaymentAccountModel> accounts = <PaymentAccountModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<PaymentAccountParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        accounts.value = list.whereType<PaymentAccountModel>().toList()
          ..sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(PaymentAccountModel item) => _openSheet(item);

  void _openSheet(PaymentAccountModel? item) {
    Get.bottomSheet(
      PaymentAccountSheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> confirmDelete(PaymentAccountModel item) async {
    final ok = await Get.dialog<bool>(
      Directionality(
        textDirection: appTextDirection,
        child: AlertDialog(
          title: Text('nursery_pay_account_delete'.tr),
          content: Text('nursery_pay_account_delete_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('common_cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('common_delete'.tr),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('nursery_pay_account_deleted'.tr);
          loadData();
        } else {
          Loader.showError('nursery_pay_account_save_error'.tr);
        }
      },
    );
  }
}
