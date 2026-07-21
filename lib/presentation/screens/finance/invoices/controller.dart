import '../../../../index/index_main.dart';

class InvoiceController extends GetxController {
  late final InvoiceParentService _service;
  late final ChildParentService _childService;
  late final _catService = Get.find<BaseService<PaymentCategoryModel>>(tag: 'paymentCategories');

  final RxList<InvoiceModel> items = <InvoiceModel>[].obs;
  final RxList<InvoiceModel> _all = <InvoiceModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxList<ChildModel> childList = <ChildModel>[].obs;
  final RxList<PaymentCategoryModel> categories = <PaymentCategoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<InvoiceParentService>();
    _childService = Get.find<ChildParentService>();
    _loadChildren();
    _loadCategories();
    loadData();
    ever(selectedStatus, (_) => _filter());
  }

  Future<void> _loadChildren() async {
    await _childService.getAll(
      callBack: (list) {
        final children = list.whereType<ChildModel>().toList();
        childList.value = children;
        final map = <String, String>{};
        for (final c in children) {
          if (c.key != null) map[c.key!] = c.fullName;
        }
        childNames.value = map;
      },
    );
  }

  Future<void> _loadCategories() async {
    await _catService.getData(
      data: {},
      voidCallBack: (list) {
        categories.value = list.whereType<PaymentCategoryModel>().where((c) => c.isActive).toList()
          ..sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<InvoiceModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _filter() {
    final s = selectedStatus.value;
    if (s.isEmpty) {
      items.value = List.from(_all);
    } else {
      items.value = _all.where((r) => r.status == s).toList();
    }
  }

  void setStatus(String s) =>
      selectedStatus.value = (selectedStatus.value == s) ? '' : s;

  String childName(String id) => childNames[id] ?? id;

  void openAdd() => _openSheet(null);
  void openEdit(InvoiceModel item) => _openSheet(item);

  void _openSheet(InvoiceModel? item) {
    final session = SessionService();
    Get.bottomSheet(
      InvoiceSheet(
        existing: item,
        children: childList,
        categories: categories,
        nurseryId: session.nurseryId ?? '',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> markAsPaid(InvoiceModel invoice) async {
    String? method;
    await Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('invoice_mark_paid_title'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('invoice_mark_paid_subtitle'.tr),
              SizedBox(height: 16.h),
              ..._payMethods.map(
                (m) => RadioListTile<String>(
                  value: m,
                  groupValue: method,
                  title: Text('payment_method_${m}'.tr),
                  onChanged: (v) {
                    method = v;
                    Get.back();
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('common_cancel'.tr),
            ),
          ],
        ),
      ),
    );

    if (method == null) return;

    Loader.show();
    final session = SessionService();
    final ok = await FinanceService().markAsPaid(
      invoice: invoice,
      paymentMethod: method!,
      receivedByName: session.currentUser?.displayName,
    );
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('invoice_paid_success'.tr);
      loadData();
      // Keep the "unpaid subscriptions" home card (manager/owner/reception) in
      // sync — settling an invoice may clear a child off it.
      if (Get.isRegistered<UnpaidSubscriptionController>()) {
        Get.find<UnpaidSubscriptionController>().load();
      }
    } else {
      Loader.showError('invoice_paid_error'.tr);
    }
  }

  Future<void> delete(InvoiceModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('invoice_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('invoice_error_failed'.tr);
        }
      },
    );
  }

  static const _payMethods = ['cash', 'card', 'bank_transfer', 'online'];
}
