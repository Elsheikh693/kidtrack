import '../../../../index/index_main.dart';

class DailyCareController extends GetxController {
  late final DailyCareLogParentService _service;
  late final ChildParentService _childService;
  late final ClassroomParentService _classroomService;

  final RxList<DailyCareLogModel> items = <DailyCareLogModel>[].obs;
  final RxList<DailyCareLogModel> _all = <DailyCareLogModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString selectedChildId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<DailyCareLogParentService>();
    _childService = Get.find<ChildParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _loadLookups();
    loadData();
    ever(selectedChildId, (_) => _filter());
  }

  Future<void> _loadLookups() async {
    await _childService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ChildModel>()) {
          if (c.key != null) map[c.key!] = c.fullName;
        }
        childNames.value = map;
      },
    );
    await _classroomService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ClassroomModel>()) {
          if (c.key != null) map[c.key!] = c.name;
        }
        classroomNames.value = map;
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<DailyCareLogModel>().toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _filter();
      },
    );
    isLoading.value = false;
  }

  void _filter() {
    final cid = selectedChildId.value;
    if (cid.isEmpty) {
      items.value = List.from(_all);
    } else {
      items.value = _all.where((r) => r.childId == cid).toList();
    }
  }

  void setChild(String id) =>
      selectedChildId.value = (selectedChildId.value == id) ? '' : id;

  String childName(String id) => childNames[id] ?? id;
  String classroomName(String id) => classroomNames[id] ?? id;

  void openAdd() => _openSheet(null);
  void openEdit(DailyCareLogModel item) => _openSheet(item);

  void _openSheet(DailyCareLogModel? item) {
    Get.bottomSheet(
      DailyCareSheet(
        initial: item,
        childNames: childNames,
        classroomNames: classroomNames,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(DailyCareLogModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('care_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('care_error_failed'.tr);
        }
      },
    );
  }
}
