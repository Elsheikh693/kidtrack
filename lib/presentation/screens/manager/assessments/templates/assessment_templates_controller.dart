import '../../../../../index/index_main.dart';

/// Lists the nursery's reusable assessment templates and owns their
/// create / edit / delete flow. Templates are nursery-wide (not branch-scoped),
/// so every branch manager/supervisor sees the same library.
class AssessmentTemplatesController extends GetxController {
  late final AssessmentTemplateParentService _service;
  late final SubjectParentService _subjectService;
  final _session = SessionService();

  final RxList<AssessmentTemplateModel> items = <AssessmentTemplateModel>[].obs;
  /// Subjects the nursery already defined — used to pick the template's subject.
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AssessmentTemplateParentService>();
    _subjectService = Get.find<SubjectParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<AssessmentTemplateModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      },
    );
    await _subjectService.getAll(
      callBack: (list) {
        subjects.value = list.whereType<SubjectModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    isLoading.value = false;
  }

  List<String> get subjectNames =>
      subjects.map((s) => s.name).where((n) => n.isNotEmpty).toList();

  void openAdd() => _openEditor(null);
  void openEdit(AssessmentTemplateModel item) => _openEditor(item);

  void _openEditor(AssessmentTemplateModel? item) {
    Get.to(
      () => AssessmentTemplateEditView(existing: item),
      transition: Transition.cupertino,
    )?.then((_) => loadData());
  }

  /// Persists a template built by the editor. Returns nothing; feedback and
  /// navigation are handled here so the view stays UI-only.
  Future<void> save(AssessmentTemplateModel model, {required bool isNew}) async {
    Loader.show();
    await _service.add(
      item: model,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess(
            isNew ? 'assessment_template_saved'.tr : 'assessment_template_updated'.tr,
          );
          Get.back();
        } else {
          Loader.showError('assessment_template_error'.tr);
        }
      },
    );
  }

  Future<void> delete(AssessmentTemplateModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('assessment_template_deleted'.tr);
          loadData();
        } else {
          Loader.showError('assessment_template_error'.tr);
        }
      },
    );
  }

  String get nurseryId => _session.nurseryId ?? '';
  String get currentUid => _session.currentUser?.uid ?? '';
}
