import '../../../../index/index_main.dart';

class BranchListController extends GetxController {
  late final BranchParentService _service;

  final RxList<BranchModel> items = <BranchModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<BranchParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<BranchModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);

  void openEdit(BranchModel branch) => _openSheet(branch);

  void _openSheet(BranchModel? branch) {
    Get.bottomSheet(
      BranchSheet(initial: branch),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(BranchModel branch) async {
    Loader.show();
    await _service.delete(
      id: branch.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('branch_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('branch_error_failed'.tr);
        }
      },
    );
  }
}
