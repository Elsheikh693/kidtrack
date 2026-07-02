import '../../../../index/index_main.dart';

class PackageListController extends GetxController {
  late final PackageParentService _service;
  late final BranchParentService _branchService;

  final RxList<PackageModel> items = <PackageModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<PackageParentService>();
    _branchService = Get.find<BranchParentService>();
    loadData();
  }

  String branchNameFor(PackageModel pkg) =>
      branchNames[pkg.branchId ?? ''] ?? '';

  Future<void> loadData() async {
    isLoading.value = true;
    await _branchService.getAll(
      callBack: (list) {
        branchNames.value = {
          for (final b in list.whereType<BranchModel>())
            (b.key ?? ''): b.name,
        };
      },
    );
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<PackageModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);

  void openEdit(PackageModel pkg) => _openSheet(pkg);

  void _openSheet(PackageModel? pkg) {
    Get.bottomSheet(
      PackageSheet(initial: pkg),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> toggleActive(PackageModel pkg) async {
    Loader.show();
    await _service.update(
      item: pkg.copyWith(isActive: !pkg.isActive),
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) loadData();
      },
    );
  }

  Future<void> delete(PackageModel pkg) async {
    Loader.show();
    await _service.delete(
      id: pkg.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('package_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('package_error_failed'.tr);
        }
      },
    );
  }
}
