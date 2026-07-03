import '../../../../index/index_main.dart';

class ProgramListController extends GetxController {
  late final ProgramParentService _service;
  late final BranchParentService _branchService;

  final RxList<ProgramModel> items = <ProgramModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ProgramParentService>();
    _branchService = Get.find<BranchParentService>();
    loadData();
  }

  /// Label for the branches a program belongs to.
  /// Empty list = available in all branches.
  String branchScopeLabel(ProgramModel p) {
    if (p.isAllBranches) return 'program_all_branches'.tr;
    final names = p.branchIds
        .map((id) => branchNames[id] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return 'program_all_branches'.tr;
    return names.join('، ');
  }

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
        items.value = list.whereType<ProgramModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(ProgramModel p) => _openSheet(p);

  void _openSheet(ProgramModel? program) {
    Get.bottomSheet(
      ProgramSheet(initial: program),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ProgramModel program) async {
    Loader.show();
    await _service.delete(
      id: program.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('program_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('program_error_failed'.tr);
        }
      },
    );
  }
}
