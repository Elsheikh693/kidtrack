import '../../../../index/index_main.dart';

class EnrollmentListController extends GetxController {
  late final EnrollmentParentService _enrollmentService;
  late final ChildParentService _childService;
  late final BranchParentService _branchService;
  late final ClassroomParentService _classroomService;

  final RxList<EnrollmentModel> items = <EnrollmentModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _enrollmentService = Get.find<EnrollmentParentService>();
    _childService = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _loadLookups();
    loadData();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      _childService.getAll(callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ChildModel>()) {
          if (c.key != null) map[c.key!] = '${c.firstName} ${c.lastName}';
        }
        childNames.value = map;
      }),
      _branchService.getAll(callBack: (list) {
        final map = <String, String>{};
        for (final b in list.whereType<BranchModel>()) {
          if (b.key != null) map[b.key!] = b.name;
        }
        branchNames.value = map;
      }),
      _classroomService.getAll(callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ClassroomModel>()) {
          if (c.key != null) map[c.key!] = c.name;
        }
        classroomNames.value = map;
      }),
    ]);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _enrollmentService.getAll(
      callBack: (list) {
        items.value = list.whereType<EnrollmentModel>().toList();
      },
    );
    isLoading.value = false;
  }

  String childName(String id) => childNames[id] ?? id;
  String branchName(String id) => branchNames[id] ?? id;
  String classroomName(String? id) => id == null ? '-' : (classroomNames[id] ?? id);

  String statusLabel(String status) {
    switch (status) {
      case 'enrolled': return 'enrollment_status_enrolled'.tr;
      case 'withdrawn': return 'enrollment_status_withdrawn'.tr;
      case 'graduated': return 'enrollment_status_graduated'.tr;
      case 'pending': return 'enrollment_status_pending'.tr;
      default: return status;
    }
  }

  void openAdd() => _openSheet(null);
  void openEdit(EnrollmentModel e) => _openSheet(e);

  void _openSheet(EnrollmentModel? e) {
    Get.bottomSheet(
      EnrollmentSheet(initial: e),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(EnrollmentModel e) async {
    Loader.show();
    await _enrollmentService.delete(
      id: e.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('enrollment_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('enrollment_error_failed'.tr);
        }
      },
    );
  }
}
