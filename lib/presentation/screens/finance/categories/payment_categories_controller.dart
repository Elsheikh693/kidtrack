import '../../../../index/index_main.dart';

class PaymentCategoriesController extends GetxController {
  late final _service = Get.find<BaseService<PaymentCategoryModel>>(tag: 'paymentCategories');

  final RxList<PaymentCategoryModel> items = <PaymentCategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        items.value = list.whereType<PaymentCategoryModel>().toList()
          ..sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(PaymentCategoryModel item) => _openSheet(item);

  void _openSheet(PaymentCategoryModel? item) {
    Get.bottomSheet(
      CategorySheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(PaymentCategoryModel item) async {
    Loader.show();
    await _service.deleteData(
      id: item.key ?? '',
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('finance_cat_deleted'.tr);
          loadData();
        } else {
          Loader.showError('finance_cat_error'.tr);
        }
      },
    );
  }
}
