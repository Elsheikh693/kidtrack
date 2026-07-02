import 'dart:io';
import '../../../../index/index_main.dart';

/// Ordered step types of the apply wizard. The [assessment] step is conditional
/// (only for children aged 4–6), so the active list is computed in [steps].
enum ApplyStepType { branch, terms, child, assessment, father, mother, bus, notes, review }

class OnlineApplicationController extends GetxController {
  final _submitService = OnlineApplicationSubmitService();
  final _catalogService = NurseryCatalogService();

  late final NurseryModel nursery;

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  /// Active steps for the current child, in the order the manager configured.
  /// Disabled sections are skipped; the assessment is additionally gated by the
  /// configured age band. [notes] and [review] aren't configurable, so they're
  /// always appended at the end.
  List<ApplyStepType> get steps {
    final result = <ApplyStepType>[];
    for (final s in _formConfig.sections) {
      if (!s.enabled) continue;
      final step = _stepForSection(s.type);
      if (step == null) continue;
      if (step == ApplyStepType.assessment && !needsAssessment) continue;
      result.add(step);
    }
    result.add(ApplyStepType.notes);
    result.add(ApplyStepType.review);
    return result;
  }

  /// The manager's form config, falling back to defaults when unset.
  ApplicationFormConfig get _formConfig =>
      nursery.applicationForm.sections.isEmpty
          ? ApplicationFormConfig.defaults()
          : nursery.applicationForm;

  ApplyStepType? _stepForSection(ApplyFormSectionType type) {
    switch (type) {
      case ApplyFormSectionType.branches:
        return ApplyStepType.branch;
      case ApplyFormSectionType.childInfo:
        return ApplyStepType.child;
      case ApplyFormSectionType.fatherInfo:
        return ApplyStepType.father;
      case ApplyFormSectionType.motherInfo:
        return ApplyStepType.mother;
      case ApplyFormSectionType.assessment:
        return ApplyStepType.assessment;
      case ApplyFormSectionType.bus:
        return ApplyStepType.bus;
      case ApplyFormSectionType.terms:
        return ApplyStepType.terms;
    }
  }

  /// The manager-authored assessment config (age band + dynamic questions).
  ApplyAssessmentConfig get assessmentConfig =>
      _formConfig.sectionOf(ApplyFormSectionType.assessment)?.assessment ??
      const ApplyAssessmentConfig();

  List<AssessmentQuestion> get assessmentQuestions =>
      assessmentConfig.questions;

  /// The manager-configured, enabled fields for a data section (child / father /
  /// mother), in display order. Empty for non-data sections.
  List<ApplyFieldConfig> fieldsFor(ApplyFormSectionType type) =>
      _formConfig.sectionOf(type)?.fields.where((f) => f.enabled).toList() ??
      const [];

  // ─── Custom (manager-added) field answers ─────────────────────────────────
  // Text/number/phone answers live in lazily-created controllers keyed by field
  // id; date/dropdown/radio/checkbox/toggle answers live in [customResponses].
  final Map<String, TextEditingController> _customControllers = {};
  final RxMap<String, dynamic> customResponses = <String, dynamic>{}.obs;

  TextEditingController customController(String fieldId) =>
      _customControllers.putIfAbsent(fieldId, () => TextEditingController());

  void setCustomValue(String fieldId, dynamic value) {
    customResponses[fieldId] = value;
  }

  dynamic customValue(String fieldId) => customResponses[fieldId];

  void toggleCustomOption(String fieldId, String option) {
    final current = List<String>.from(
        (customResponses[fieldId] as List?)?.cast<String>() ?? const []);
    current.contains(option) ? current.remove(option) : current.add(option);
    customResponses[fieldId] = current;
  }

  int get stepCount => steps.length;

  // ─── Branch + packages (catalog) ──────────────────────────────────────────
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxBool isLoadingCatalog = false.obs;

  final RxnString selectedBranchId = RxnString();
  final RxnString selectedBranchName = RxnString();
  final RxList<String> selectedPackageIds = <String>[].obs;

  // ─── Child ──────────────────────────────────────────────────────────────--
  final childName = TextEditingController();
  final childAddress = TextEditingController();
  final RxnString childGender = RxnString();
  final RxnString childBloodType = RxnString();
  final Rxn<DateTime> childDob = Rxn<DateTime>();
  final RxString childNationality = 'مصري'.obs;
  final RxnString childPhoto = RxnString();
  final RxBool isUploadingPhoto = false.obs;

  // ─── Father ─────────────────────────────────────────────────────────────--
  final fatherName = TextEditingController();
  final fatherPhone = TextEditingController();
  final fatherJob = TextEditingController();
  final fatherNationalId = TextEditingController();

  // ─── Mother ─────────────────────────────────────────────────────────────--
  final motherName = TextEditingController();
  final motherPhone = TextEditingController();
  final motherJob = TextEditingController();
  final motherNationalId = TextEditingController();

  // ─── Assessment (4–6 years only) ──────────────────────────────────────────
  final RxMap<String, String> assessmentRatings = <String, String>{}.obs;
  final assessmentNotes = TextEditingController();

  // ─── Bus subscription (optional) ──────────────────────────────────────────
  final RxBool wantsBus = false.obs;
  final busAddress = TextEditingController();

  final RxString primaryContact = 'father'.obs;
  final notes = TextEditingController();
  final RxBool agreed = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    nursery = Get.arguments as NurseryModel;
    _loadCatalog();
  }

  String? get primaryPhone => primaryContact.value == 'mother'
      ? motherPhone.text.trim()
      : fatherPhone.text.trim();

  void setGender(String value) => childGender.value = value;
  void setBloodType(String? value) => childBloodType.value = value;
  void setNationality(String value) => childNationality.value = value;
  void setPrimaryContact(String value) => primaryContact.value = value;
  void toggleAgreed(bool? value) => agreed.value = value ?? false;
  void setDob(DateTime value) => childDob.value = value;

  /// Whether the conditional assessment step applies: the section is enabled,
  /// the manager authored at least one question, and the child's age falls
  /// within the configured band.
  bool get needsAssessment {
    final dob = childDob.value;
    if (dob == null) return false;
    final section = _formConfig.sectionOf(ApplyFormSectionType.assessment);
    if (section == null || !section.enabled) return false;
    if (section.assessment.questions.isEmpty) return false;
    return section.assessment.appliesToAge(_ageInYears(dob));
  }

  int _ageInYears(DateTime dob) {
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  void setAssessmentRating(String itemId, String value) {
    assessmentRatings[itemId] = value;
  }

  /// Toggles bus opt-in. On enable, seed the pickup address from the child's
  /// address (entered earlier) when it hasn't been filled yet.
  void toggleBus(bool value) {
    wantsBus.value = value;
    if (value && busAddress.text.trim().isEmpty) {
      busAddress.text = childAddress.text.trim();
    }
  }

  /// Picks and uploads the child's photo (mandatory). Stored under the chosen
  /// nursery's online-applications folder so it survives before the parent has
  /// an account.
  Future<void> pickChildPhoto() async {
    if (isUploadingPhoto.value) return;
    await PickedImage().pickImage(callBack: (file) async {
      if (file == null) return;
      await _uploadChildPhoto(file);
    });
  }

  Future<void> _uploadChildPhoto(File file) async {
    isUploadingPhoto.value = true;
    final nurseryId = nursery.key ?? '';
    final key =
        'onlineApplications/$nurseryId/${const Uuid().v4()}_child.jpg';
    final result =
        await Get.find<FirebaseCredentialsService>().uploadImage(key, file);
    result.fold(
      (_) => Loader.showError('apply_photo_upload_error'.tr),
      (url) => childPhoto.value = url,
    );
    isUploadingPhoto.value = false;
  }

  // ─── Catalog (branches + packages) ────────────────────────────────────────

  Future<void> _loadCatalog() async {
    final id = nursery.key ?? '';
    if (id.isEmpty) return;
    isLoadingCatalog.value = true;
    final results = await Future.wait([
      _catalogService.branches(id),
      _catalogService.packages(id),
    ]);
    branches.assignAll(results[0] as List<BranchModel>);
    packages.assignAll(results[1] as List<PackageModel>);
    // Pre-select the first branch so its package + total show immediately.
    if (branches.isNotEmpty) {
      selectBranch(branches.first);
    }
    isLoadingCatalog.value = false;
  }

  /// Packages applicable to the chosen branch: branch-specific ones plus any
  /// nursery-wide packages (no branchId).
  List<PackageModel> get branchPackages {
    final bid = selectedBranchId.value;
    if (bid == null) return const [];
    return packages
        .where((p) =>
            (p.branchId ?? '').isEmpty || p.branchId == bid)
        .toList();
  }

  double get selectedTotal {
    double sum = 0;
    for (final p in branchPackages) {
      if (selectedPackageIds.contains(p.key)) sum += p.price;
    }
    return sum;
  }

  void selectBranch(BranchModel branch) {
    if (selectedBranchId.value == branch.key) return;
    selectedBranchId.value = branch.key;
    selectedBranchName.value = branch.name;
    selectedPackageIds.clear();
    // When the branch offers a single package it's auto-included (display-only),
    // so its value is reflected in the total without any tap.
    final pkgs = branchPackages;
    if (pkgs.length == 1) {
      selectedPackageIds.add(pkgs.first.key ?? '');
    }
  }

  void togglePackage(String id) {
    if (selectedPackageIds.contains(id)) {
      selectedPackageIds.remove(id);
    } else {
      selectedPackageIds.add(id);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void nextStep() {
    if (!_validateStep(steps[currentStep.value])) return;
    if (currentStep.value < stepCount - 1) {
      currentStep.value++;
      _animate();
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      _animate();
    }
  }

  void _animate() {
    pageController.animateToPage(
      currentStep.value,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _validateStep(ApplyStepType step) {
    switch (step) {
      case ApplyStepType.branch:
        if ((selectedBranchId.value ?? '').isEmpty) {
          Loader.showError('apply_err_branch'.tr);
          return false;
        }
        if (branchPackages.isNotEmpty && selectedPackageIds.isEmpty) {
          Loader.showError('apply_err_packages'.tr);
          return false;
        }
        return true;
      case ApplyStepType.terms:
        if (!agreed.value) {
          Loader.showError('apply_err_terms'.tr);
          return false;
        }
        return true;
      case ApplyStepType.child:
        return _validateDataSection(ApplyFormSectionType.childInfo);
      case ApplyStepType.assessment:
        final answered = assessmentQuestions
            .where((q) => assessmentRatings.containsKey(q.id))
            .length;
        if (answered < assessmentQuestions.length) {
          Loader.showError('apply_err_asmt_incomplete'.tr);
          return false;
        }
        return true;
      case ApplyStepType.father:
        return _validateDataSection(ApplyFormSectionType.fatherInfo);
      case ApplyStepType.mother:
        return _validateDataSection(ApplyFormSectionType.motherInfo);
      case ApplyStepType.bus:
        if (wantsBus.value && busAddress.text.trim().isEmpty) {
          Loader.showError('apply_err_bus_address'.tr);
          return false;
        }
        return true;
      case ApplyStepType.notes:
      case ApplyStepType.review:
        return true;
    }
  }

  // ─── Dynamic data-section validation ──────────────────────────────────────

  /// Validates every enabled field of a data section against its config:
  /// required fields must be filled, and phone fields must be well-formed.
  /// Shows (and returns false on) the first problem, naming the offending field.
  bool _validateDataSection(ApplyFormSectionType type) {
    for (final f in fieldsFor(type)) {
      final label = f.label.isNotEmpty ? f.label : f.labelKey.tr;
      if (f.required && !_isFieldFilled(f)) {
        Loader.showError('${'apply_err_required_field'.tr}$label');
        return false;
      }
      if (_isPhoneField(f)) {
        final phone = _fieldText(f);
        if (phone.isNotEmpty &&
            Validators.validatePhone(phone) != null) {
          Loader.showError('${'apply_err_invalid_phone'.tr}$label');
          return false;
        }
      }
    }
    return true;
  }

  bool _isPhoneField(ApplyFieldConfig f) =>
      f.type == ApplyFieldType.phone ||
      f.systemRole == ApplyFieldRoles.fatherPhone ||
      f.systemRole == ApplyFieldRoles.motherPhone;

  /// The current text answer of a text-like field (system or custom).
  String _fieldText(ApplyFieldConfig f) {
    switch (f.systemRole) {
      case ApplyFieldRoles.childName:
        return childName.text.trim();
      case ApplyFieldRoles.childAddress:
        return childAddress.text.trim();
      case ApplyFieldRoles.fatherName:
        return fatherName.text.trim();
      case ApplyFieldRoles.fatherPhone:
        return fatherPhone.text.trim();
      case ApplyFieldRoles.fatherJob:
        return fatherJob.text.trim();
      case ApplyFieldRoles.fatherNationalId:
        return fatherNationalId.text.trim();
      case ApplyFieldRoles.motherName:
        return motherName.text.trim();
      case ApplyFieldRoles.motherPhone:
        return motherPhone.text.trim();
      case ApplyFieldRoles.motherJob:
        return motherJob.text.trim();
      case ApplyFieldRoles.motherNationalId:
        return motherNationalId.text.trim();
      default:
        return customController(f.id).text.trim();
    }
  }

  /// Whether a field currently holds an answer (used for required checks).
  bool _isFieldFilled(ApplyFieldConfig f) {
    switch (f.systemRole) {
      case ApplyFieldRoles.childPhoto:
        return (childPhoto.value ?? '').isNotEmpty;
      case ApplyFieldRoles.childGender:
        return (childGender.value ?? '').isNotEmpty;
      case ApplyFieldRoles.childDob:
        return childDob.value != null;
      case ApplyFieldRoles.childNationality:
        return childNationality.value.isNotEmpty;
      case ApplyFieldRoles.childBlood:
        return (childBloodType.value ?? '').isNotEmpty;
      case ApplyFieldRoles.childName:
      case ApplyFieldRoles.childAddress:
      case ApplyFieldRoles.fatherName:
      case ApplyFieldRoles.fatherPhone:
      case ApplyFieldRoles.fatherJob:
      case ApplyFieldRoles.fatherNationalId:
      case ApplyFieldRoles.motherName:
      case ApplyFieldRoles.motherPhone:
      case ApplyFieldRoles.motherJob:
      case ApplyFieldRoles.motherNationalId:
        return _fieldText(f).isNotEmpty;
      default:
        return _isCustomFilled(f);
    }
  }

  bool _isCustomFilled(ApplyFieldConfig f) {
    switch (f.type) {
      case ApplyFieldType.date:
        return customResponses[f.id] is int;
      case ApplyFieldType.dropdown:
      case ApplyFieldType.radio:
        return (customResponses[f.id]?.toString() ?? '').isNotEmpty;
      case ApplyFieldType.checkbox:
        return (customResponses[f.id] as List?)?.isNotEmpty ?? false;
      case ApplyFieldType.toggle:
        return customResponses[f.id] == true;
      default:
        return customController(f.id).text.trim().isNotEmpty;
    }
  }

  /// Snapshots every custom (manager-added) field that has an answer across the
  /// data sections, with its label + display value, for the manager's review.
  List<ApplicationCustomField> _collectCustomFields() {
    const types = [
      ApplyFormSectionType.childInfo,
      ApplyFormSectionType.fatherInfo,
      ApplyFormSectionType.motherInfo,
    ];
    final result = <ApplicationCustomField>[];
    for (final type in types) {
      for (final f in fieldsFor(type)) {
        if (f.systemRole != null) continue; // built-ins are stored explicitly
        final value = _customDisplayValue(f);
        if (value.isEmpty) continue;
        result.add(ApplicationCustomField(
          section: type.id,
          label: f.label,
          value: value,
        ));
      }
    }
    return result;
  }

  String _customDisplayValue(ApplyFieldConfig f) {
    switch (f.type) {
      case ApplyFieldType.date:
        final v = customResponses[f.id];
        if (v is! int) return '';
        final d = DateTime.fromMillisecondsSinceEpoch(v);
        return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
      case ApplyFieldType.dropdown:
      case ApplyFieldType.radio:
        return customResponses[f.id]?.toString() ?? '';
      case ApplyFieldType.checkbox:
        final list =
            (customResponses[f.id] as List?)?.cast<String>() ?? const [];
        return list.join('، ');
      case ApplyFieldType.toggle:
        return customResponses[f.id] == true
            ? 'apply_toggle_yes'.tr
            : 'apply_toggle_no'.tr;
      default:
        return customController(f.id).text.trim();
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!agreed.value) {
      Loader.showError('apply_err_agreement'.tr);
      return;
    }
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    Loader.show();

    final nameParts = childName.text.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.first;
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final selectedPkgs = branchPackages
        .where((p) => selectedPackageIds.contains(p.key))
        .map((p) => ApplicationPackage(
              id: p.key ?? '',
              name: p.name,
              price: p.price,
              duration: p.duration,
            ))
        .toList();

    final model = OnlineApplicationModel(
      nurseryId: nursery.key ?? '',
      nurseryName: nursery.name,
      branchId: selectedBranchId.value,
      branchName: selectedBranchName.value,
      selectedPackages: selectedPkgs,
      childFirstName: firstName,
      childLastName: lastName,
      childPhoto: childPhoto.value,
      childGender: childGender.value,
      childDateOfBirth: childDob.value?.millisecondsSinceEpoch,
      childNationality: _orNull(childNationality.value),
      childBloodType: childBloodType.value,
      childAddress: _orNull(childAddress.text),
      fatherName: fatherName.text.trim(),
      fatherPhone: fatherPhone.text.trim(),
      fatherJob: _orNull(fatherJob.text),
      fatherNationalId: _orNull(fatherNationalId.text),
      motherName: motherName.text.trim(),
      motherPhone: motherPhone.text.trim(),
      motherJob: _orNull(motherJob.text),
      motherNationalId: _orNull(motherNationalId.text),
      primaryContact: primaryContact.value,
      notes: _orNull(notes.text),
      agreed: true,
      busSubscription: wantsBus.value,
      busAddress: wantsBus.value ? _orNull(busAddress.text) : null,
      assessment: needsAssessment
          ? ApplicationAssessment(
              ratings: Map<String, String>.from(assessmentRatings),
              questions: List<AssessmentQuestion>.from(assessmentQuestions),
              notes: _orNull(assessmentNotes.text),
            )
          : null,
      customFields: _collectCustomFields(),
    );

    final ok = await _submitService.submit(model);
    Loader.dismiss();
    isSubmitting.value = false;

    if (ok) {
      Get.off(() => const ApplySuccessView());
    } else {
      Loader.showError('apply_submit_error'.tr);
    }
  }

  String? _orNull(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  void onClose() {
    pageController.dispose();
    childName.dispose();
    childAddress.dispose();
    fatherName.dispose();
    fatherPhone.dispose();
    fatherJob.dispose();
    fatherNationalId.dispose();
    motherName.dispose();
    motherPhone.dispose();
    motherJob.dispose();
    motherNationalId.dispose();
    assessmentNotes.dispose();
    busAddress.dispose();
    notes.dispose();
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
