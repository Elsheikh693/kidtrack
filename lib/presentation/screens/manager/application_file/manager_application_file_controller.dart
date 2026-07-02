import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

/// Configures the "Application File" (ملف التقديم) — everything the nursery
/// decides about how parents apply. Owns the file-opening fee, the enrollment
/// terms, and the fully dynamic apply-form: the ordered, toggleable sections
/// plus the assessment questions and bus note. Reads/writes the Discovery node.
class ManagerApplicationFileController extends GetxController {
  final _session = SessionService();

  // ─── Fee ────────────────────────────────────────────────────────────────--
  final applicationFeeCtrl = TextEditingController();
  final applicationFeeFree = false.obs;

  // ─── Terms ──────────────────────────────────────────────────────────────--
  final terms = <String>[].obs;

  // ─── Ordered sections (order + enabled is the source of truth here) ───────
  final sections = <ApplyFormSection>[].obs;

  // ─── Assessment editing state (assembled back onto its section on save) ───
  final asmtMinAge = 3.obs;
  final asmtMaxAge = 5.obs;
  final questions = <AssessmentQuestion>[].obs;

  // ─── Bus note ─────────────────────────────────────────────────────────────
  final busNoteCtrl = TextEditingController();

  final isLoading = true.obs;
  final isSaving = false.obs;

  String get nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('platform/info/$nurseryId');

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    if (nurseryId.isEmpty) {
      sections.assignAll(ApplicationFormConfig.defaults().sections);
      isLoading.value = false;
      return;
    }
    try {
      final snap = await _ref.get();
      if (snap.exists && snap.value is Map) {
        final model = NurseryModel.fromJson(
          Map<String, dynamic>.from(snap.value as Map),
          key: nurseryId,
        );
        applicationFeeFree.value = model.applicationFeeFree;
        applicationFeeCtrl.text = model.applicationFee == null
            ? ''
            : model.applicationFee!.toStringAsFixed(0);
        terms.assignAll(model.terms);

        final config = model.applicationForm.sections.isEmpty
            ? ApplicationFormConfig.defaults()
            : model.applicationForm;
        sections.assignAll(config.sections);

        final asmt = config.sectionOf(ApplyFormSectionType.assessment);
        if (asmt != null) {
          asmtMinAge.value = asmt.assessment.minAgeYears;
          asmtMaxAge.value = asmt.assessment.maxAgeYears;
          questions.assignAll(asmt.assessment.questions);
        }
        final busSection = config.sectionOf(ApplyFormSectionType.bus);
        busNoteCtrl.text = busSection?.bus.note ?? '';
      } else {
        sections.assignAll(ApplicationFormConfig.defaults().sections);
      }
    } catch (_) {
      sections.assignAll(ApplicationFormConfig.defaults().sections);
      Loader.showError('manager_profile_load_error'.tr);
    }
    isLoading.value = false;
  }

  // ─── Section ordering + toggling ──────────────────────────────────────────

  void reorderSections(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = sections.removeAt(oldIndex);
    sections.insert(newIndex, item);
  }

  void toggleSection(int index, bool enabled) {
    if (index < 0 || index >= sections.length) return;
    sections[index] = sections[index].copyWith(enabled: enabled);
  }

  // ─── Per-section fields (child / father / mother builders) ─────────────────

  List<ApplyFieldConfig> fieldsOf(ApplyFormSectionType type) =>
      sections.firstWhereOrNull((s) => s.type == type)?.fields ?? const [];

  void _mutateFields(
    ApplyFormSectionType type,
    List<ApplyFieldConfig> Function(List<ApplyFieldConfig>) transform,
  ) {
    final index = sections.indexWhere((s) => s.type == type);
    if (index < 0) return;
    final next = transform(List<ApplyFieldConfig>.from(sections[index].fields));
    sections[index] = sections[index].copyWith(fields: next);
  }

  void addField(ApplyFormSectionType type, ApplyFieldConfig field) =>
      _mutateFields(type, (list) => list..add(field));

  void updateField(ApplyFormSectionType type, ApplyFieldConfig field) {
    _mutateFields(type, (list) {
      final i = list.indexWhere((f) => f.id == field.id);
      if (i >= 0) list[i] = field;
      return list;
    });
  }

  void removeField(ApplyFormSectionType type, String fieldId) {
    _mutateFields(type, (list) {
      final f = list.firstWhereOrNull((e) => e.id == fieldId);
      if (f == null || f.isSystem) return list; // system fields can't be deleted
      return list..removeWhere((e) => e.id == fieldId);
    });
  }

  void toggleFieldEnabled(
      ApplyFormSectionType type, String fieldId, bool enabled) {
    _mutateFields(type, (list) {
      final i = list.indexWhere((f) => f.id == fieldId);
      if (i >= 0 && !list[i].isLocked) {
        list[i] = list[i].copyWith(enabled: enabled);
      }
      return list;
    });
  }

  void toggleFieldRequired(
      ApplyFormSectionType type, String fieldId, bool required) {
    _mutateFields(type, (list) {
      final i = list.indexWhere((f) => f.id == fieldId);
      if (i >= 0 && !list[i].isLocked) {
        list[i] = list[i].copyWith(required: required);
      }
      return list;
    });
  }

  void reorderFields(ApplyFormSectionType type, int oldIndex, int newIndex) {
    _mutateFields(type, (list) {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      return list;
    });
  }

  // ─── Assessment ───────────────────────────────────────────────────────────

  void setAssessmentAge({int? min, int? max}) {
    if (min != null) asmtMinAge.value = min;
    if (max != null) asmtMaxAge.value = max;
    if (asmtMaxAge.value < asmtMinAge.value) {
      asmtMaxAge.value = asmtMinAge.value;
    }
  }

  void addQuestion(String text) {
    final v = text.trim();
    if (v.isEmpty) return;
    questions.add(AssessmentQuestion.create(v));
  }

  void removeQuestion(String id) =>
      questions.removeWhere((q) => q.id == id);

  // ─── Terms ────────────────────────────────────────────────────────────────

  void addTerm(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    terms.add(v);
  }

  void removeTerm(String value) => terms.remove(value);

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> save() async {
    if (nurseryId.isEmpty) return;
    isSaving.value = true;
    Loader.show();
    try {
      final feeText = applicationFeeCtrl.text.trim();
      final applicationFee = feeText.isEmpty ? null : double.tryParse(feeText);
      final config = ApplicationFormConfig(sections: _assembledSections());
      await _ref.update({
        'applicationFee': applicationFeeFree.value ? null : applicationFee,
        'applicationFeeFree': applicationFeeFree.value,
        'terms': terms.toList(),
        'applicationForm': config.toJson(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      Loader.showSuccess('manager_profile_saved'.tr);
      Get.back();
    } catch (_) {
      Loader.showError('manager_profile_save_error'.tr);
    }
    isSaving.value = false;
  }

  /// Folds the dedicated assessment/bus editing state back onto their sections,
  /// preserving the current order + enabled flags.
  List<ApplyFormSection> _assembledSections() {
    return sections.map((s) {
      switch (s.type) {
        case ApplyFormSectionType.assessment:
          return s.copyWith(
            assessment: ApplyAssessmentConfig(
              minAgeYears: asmtMinAge.value,
              maxAgeYears: asmtMaxAge.value,
              questions: questions.toList(),
            ),
          );
        case ApplyFormSectionType.bus:
          return s.copyWith(
            bus: ApplyBusConfig(note: busNoteCtrl.text.trim()),
          );
        default:
          return s;
      }
    }).toList();
  }

  @override
  void onClose() {
    applicationFeeCtrl.dispose();
    busNoteCtrl.dispose();
    super.onClose();
  }
}
