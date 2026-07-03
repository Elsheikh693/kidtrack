import '../../../../index/index_main.dart';

class SubjectListController extends GetxController {
  late final SubjectParentService _service;
  late final BranchParentService _branchService;

  final RxList<SubjectModel> items = <SubjectModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<SubjectParentService>();
    _branchService = Get.find<BranchParentService>();
    loadData();
  }

  String branchScopeLabel(SubjectModel s) {
    if (s.isAllBranches) return 'subject_all_branches'.tr;
    final names = s.branchIds
        .map((id) => branchNames[id] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return 'subject_all_branches'.tr;
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
        items.value = list.whereType<SubjectModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);

  void openEdit(SubjectModel s) => _openSheet(s);

  void _openSheet(SubjectModel? subject) {
    Get.bottomSheet(
      SubjectSheet(initial: subject),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(SubjectModel subject) async {
    Loader.show();
    await _service.delete(
      id: subject.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('subject_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('subject_error_failed'.tr);
        }
      },
    );
  }
}
