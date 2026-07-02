import '../../../../index/index_main.dart';

class ClassroomListController extends GetxController {
  late final ClassroomParentService _service;
  late final BranchParentService _branchService;
  late final StaffParentService _staffService;

  final RxList<ClassroomModel> items = <ClassroomModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxMap<String, String> teacherNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ClassroomParentService>();
    _branchService = Get.find<BranchParentService>();
    _staffService = Get.find<StaffParentService>();
    _loadLookups();
    loadData();
  }

  Future<void> _loadLookups() async {
    await _branchService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final b in list.whereType<BranchModel>()) {
          if (b.key != null) map[b.key!] = b.name;
        }
        branchNames.value = map;
      },
    );
    await _staffService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final s in list.whereType<StaffModel>()) {
          if (s.key != null) map[s.key!] = s.name;
        }
        teacherNames.value = map;
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<ClassroomModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  String branchName(String id) => branchNames[id] ?? id;
  String teacherName(String? id) => id == null ? 'classroom_teacher_none'.tr : (teacherNames[id] ?? id);

  /// Label for the branches a classroom belongs to.
  /// Empty list = available in all branches.
  String branchScopeLabel(ClassroomModel c) {
    if (c.isAllBranches) return 'classroom_all_branches'.tr;
    final names = c.branchIds
        .map((id) => branchNames[id] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return 'classroom_all_branches'.tr;
    return names.join('، ');
  }

  void openDetail(ClassroomModel classroom) {
    Get.toNamed(classroomDetailView, arguments: classroom);
  }

  void openAdd() => _openSheet(null);
  void openEdit(ClassroomModel c) => _openSheet(c);

  void _openSheet(ClassroomModel? classroom) {
    Get.bottomSheet(
      ClassroomSheet(initial: classroom),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ClassroomModel classroom) async {
    Loader.show();
    await _service.delete(
      id: classroom.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('classroom_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('classroom_error_failed'.tr);
        }
      },
    );
  }
}
