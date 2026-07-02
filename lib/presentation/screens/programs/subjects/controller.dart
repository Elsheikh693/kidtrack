import '../../../../index/index_main.dart';

class SubjectListController extends GetxController {
  late final SubjectParentService _service;
  late final ProgramParentService _programService;
  late final BranchParentService _branchService;
  ProgramModel? program;

  final RxList<SubjectModel> items = <SubjectModel>[].obs;
  final RxList<ProgramModel> programs = <ProgramModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;

  bool get isAllMode => program == null;

  @override
  void onInit() {
    super.onInit();
    program = Get.arguments is ProgramModel ? Get.arguments as ProgramModel : null;
    _service = Get.find<SubjectParentService>();
    _programService = Get.find<ProgramParentService>();
    _branchService = Get.find<BranchParentService>();
    if (isAllMode) _loadPrograms();
    loadData();
  }

  Future<void> _loadPrograms() async {
    await _programService.getAll(
      callBack: (list) {
        programs.value = list.whereType<ProgramModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
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
        final all = list.whereType<SubjectModel>();
        items.value = (program == null
                ? all
                : all.where((s) => s.programId == program!.key))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null, program);

  void openEdit(SubjectModel s) {
    final p = program ?? ProgramModel(key: s.programId, nurseryId: '', name: '');
    _openSheet(s, p);
  }

  void _openSheet(SubjectModel? subject, ProgramModel? p) {
    Get.bottomSheet(
      SubjectSheet(
        initial: subject,
        program: p,
        programs: programs,
      ),
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
