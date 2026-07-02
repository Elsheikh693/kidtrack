import '../../../../index/index_main.dart';

class PaymentController extends GetxController {
  late final PaymentParentService _service;
  late final ChildParentService _childService;
  late final _catService = Get.find<BaseService<PaymentCategoryModel>>(tag: 'paymentCategories');
  late final _invoiceService = Get.find<InvoiceParentService>();

  final RxList<PaymentModel> items = <PaymentModel>[].obs;
  final RxList<PaymentModel> _all = <PaymentModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxList<ChildModel> childList = <ChildModel>[].obs;
  final RxList<PaymentCategoryModel> categories = <PaymentCategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<PaymentParentService>();
    _childService = Get.find<ChildParentService>();
    _loadLookups();
    loadData();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      _childService.getAll(
        callBack: (list) {
          final children = list.whereType<ChildModel>().toList();
          childList.value = children;
          childNames.value = {
            for (final c in children)
              if (c.key != null) c.key!: c.fullName
          };
        },
      ),
      _catService.getData(
        data: {},
        voidCallBack: (list) {
          categories.value = list
              .whereType<PaymentCategoryModel>()
              .where((c) => c.isActive)
              .toList()
            ..sort((a, b) => (a.createdAt ?? 0).compareTo(b.createdAt ?? 0));
        },
      ),
    ]);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<PaymentModel>().toList()
          ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
        items.value = List.from(_all);
      },
    );
    isLoading.value = false;
  }

  String childName(String id) => childNames[id] ?? id;

  void openAdd() {
    final session = SessionService();
    Get.bottomSheet(
      PaymentSheet(
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

  Future<void> savePayment({
    required String childId,
    required String? parentId,
    required PaymentCategoryModel? category,
    required double amount,
    required String method,
    required String? notes,
    required String nurseryId,
  }) async {
    Loader.show();
    final now = DateTime.now().millisecondsSinceEpoch;
    final session = SessionService();

    // 1. Create invoice (already paid)
    final invoiceKey = 'inv_$now';
    final invoice = InvoiceModel(
      key: invoiceKey,
      nurseryId: nurseryId,
      childId: childId,
      parentId: parentId,
      categoryId: category?.key,
      categoryName: category?.name,
      amount: amount,
      discount: 0,
      totalAmount: amount,
      status: 'paid',
      dueDate: now,
      paidAt: now,
      paidBy: session.currentUser?.displayName,
      paymentMethod: method,
      notes: notes,
      createdAt: now,
    );

    bool invoiceOk = false;
    await _invoiceService.add(
      item: invoice,
      callBack: (s) => invoiceOk = s == ResponseStatus.success,
    );

    if (!invoiceOk) {
      Loader.dismiss();
      Loader.showError('payment_error_failed'.tr);
      return;
    }

    // 2. Create payment record
    final paymentKey = 'pay_$now';
    final payment = PaymentModel(
      key: paymentKey,
      nurseryId: nurseryId,
      invoiceId: invoiceKey,
      childId: childId,
      parentId: parentId,
      categoryId: category?.key,
      categoryName: category?.name,
      amount: amount,
      method: method,
      receivedBy: session.currentUser?.displayName,
      paidAt: now,
    );

    await _service.add(
      item: payment,
      callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) {
          Loader.showSuccess('payment_success'.tr);
          loadData();
        } else {
          Loader.showError('payment_error_failed'.tr);
        }
      },
    );
  }

  Future<void> delete(PaymentModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('payment_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('payment_error_failed'.tr);
        }
      },
    );
  }
}
