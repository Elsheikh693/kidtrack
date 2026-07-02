import '../../../../index/index_main.dart';
import '../profile/widgets/profile_terms_editor.dart';
import 'widgets/application_fee_editor.dart';
import 'widgets/section_fields_editor.dart';

/// The dynamic "Application File" builder. The manager reorders the apply-form
/// sections (drag), toggles each on/off, and configures the ones that carry
/// settings: the file-opening fee, the age-gated assessment with its dynamic
/// questions, the bus note, and the enrollment terms. Everything is persisted
/// to the nursery's Discovery node by [ManagerApplicationFileController].
class ManagerApplicationFileView extends StatefulWidget {
  const ManagerApplicationFileView({super.key});

  @override
  State<ManagerApplicationFileView> createState() =>
      _ManagerApplicationFileViewState();
}

class _ManagerApplicationFileViewState extends State<ManagerApplicationFileView>
    with KeyboardSheetMixin {
  late final ManagerApplicationFileController controller;

  /// Section ids whose inline editor is currently expanded.
  final _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    controller = initController(() => ManagerApplicationFileController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'manager_application_file_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return wrapWithKeyboard(
            context: context,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _intro(context),
                  SizedBox(height: 20.h),
                  _blockTitle(context, 'manager_profile_app_fee_section'.tr),
                  SizedBox(height: 10.h),
                  ApplicationFeeEditor(
                    feeCtrl: controller.applicationFeeCtrl,
                    free: controller.applicationFeeFree,
                  ),
                  SizedBox(height: 24.h),
                  _blockTitle(
                      context, 'manager_apply_builder_sections_title'.tr),
                  SizedBox(height: 12.h),
                  Obx(() => _sectionsList(context)),
                  SizedBox(height: 20.h),
                  Obx(
                    () => PrimaryTextButton(
                      label: AppText(
                        text: 'manager_profile_save'.tr,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.white),
                      ),
                      appButtonSize: AppButtonSize.large,
                      onTap:
                          controller.isSaving.value ? null : controller.save,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: 'manager_apply_builder_intro'.tr,
              textStyle: context.typography.xsRegular.copyWith(
                color: AppColors.textPrimaryParagraph,
                height: 1.6,
              ),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockTitle(BuildContext context, String title) {
    return AppText(
      text: title,
      textStyle: context.typography.smSemiBold
          .copyWith(color: AppColors.textPrimaryParagraph),
    );
  }

  Widget _sectionsList(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: controller.sections.length,
      onReorder: controller.reorderSections,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      itemBuilder: (context, index) {
        final section = controller.sections[index];
        return Padding(
          key: ValueKey(section.type.id),
          padding: EdgeInsets.only(bottom: 12.h),
          child: _SectionCard(
            controller: controller,
            section: section,
            index: index,
            expanded: _expanded.contains(section.type.id),
            onToggleExpand: () => setState(() {
              final id = section.type.id;
              _expanded.contains(id)
                  ? _expanded.remove(id)
                  : _expanded.add(id);
            }),
            onToggleEnabled: (v) => controller.toggleSection(index, v),
          ),
        );
      },
    );
  }
}

/// One draggable, toggleable section row plus its (optional) inline editor.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.controller,
    required this.section,
    required this.index,
    required this.expanded,
    required this.onToggleExpand,
    required this.onToggleEnabled,
  });

  final ManagerApplicationFileController controller;
  final ApplyFormSection section;
  final int index;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<bool> onToggleEnabled;

  bool get _hasEditor =>
      section.collectsFields ||
      section.type == ApplyFormSectionType.assessment ||
      section.type == ApplyFormSectionType.bus ||
      section.type == ApplyFormSectionType.terms;

  /// Short helper line under simple (non-editable) steps; null when the section
  /// has its own inline editor (the chevron signals tappability instead).
  String? get _subtitleKey {
    switch (section.type) {
      case ApplyFormSectionType.branches:
        return 'manager_apply_branches_note';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = section.enabled;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.grayLight,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: _hasEditor && enabled ? onToggleExpand : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_indicator_rounded,
                        size: 22.sp, color: AppColors.grayMedium),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: (enabled ? AppColors.primary : AppColors.grayMedium)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _iconFor(section.type.icon),
                      size: 20.sp,
                      color: enabled ? AppColors.primary : AppColors.grayMedium,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: section.type.labelKey.tr,
                          textStyle: context.typography.smSemiBold.copyWith(
                            color: enabled
                                ? AppColors.textDefault
                                : AppColors.grayMedium,
                          ),
                        ),
                        if (enabled && _subtitleKey != null)
                          AppText(
                            text: _subtitleKey!.tr,
                            textStyle: context.typography.xsRegular.copyWith(
                                color: AppColors.grayMedium, height: 1.4),
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                  if (_hasEditor && enabled)
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 22.sp,
                      color: AppColors.grayMedium,
                    ),
                  SizedBox(width: 4.w),
                  Switch.adaptive(
                    value: enabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: onToggleEnabled,
                  ),
                ],
              ),
            ),
          ),
          if (enabled)
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: (_hasEditor && expanded)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                      child: _editorFor(context),
                    )
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }

  Widget _editorFor(BuildContext context) {
    switch (section.type) {
      case ApplyFormSectionType.childInfo:
      case ApplyFormSectionType.fatherInfo:
      case ApplyFormSectionType.motherInfo:
        return SectionFieldsEditor(controller: controller, type: section.type);
      case ApplyFormSectionType.assessment:
        return _AssessmentEditor(controller: controller);
      case ApplyFormSectionType.bus:
        return _BusEditor(controller: controller);
      case ApplyFormSectionType.terms:
        return ProfileTermsEditor(
          hint: 'manager_profile_terms_hint'.tr,
          items: controller.terms,
          onAdd: controller.addTerm,
          onRemove: controller.removeTerm,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'storefront':
        return Icons.storefront_rounded;
      case 'child':
        return Icons.child_care_rounded;
      case 'man':
        return Icons.man_rounded;
      case 'woman':
        return Icons.woman_rounded;
      case 'assessment':
        return Icons.fact_check_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'terms':
        return Icons.gavel_rounded;
      default:
        return Icons.tune_rounded;
    }
  }
}

/// Bus section editor: just an optional explanatory note, since the price is
/// settled directly with the nursery.
class _BusEditor extends StatelessWidget {
  const _BusEditor({required this.controller});

  final ManagerApplicationFileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hintRow(context, 'manager_apply_bus_price_note'.tr),
        SizedBox(height: 10.h),
        AppTextField(
          controller: controller.busNoteCtrl,
          hintText: 'manager_apply_bus_note_hint'.tr,
          maxLines: 3,
        ),
      ],
    );
  }
}

/// Assessment editor: age band (whole years) plus the dynamic question list.
class _AssessmentEditor extends StatefulWidget {
  const _AssessmentEditor({required this.controller});

  final ManagerApplicationFileController controller;

  @override
  State<_AssessmentEditor> createState() => _AssessmentEditorState();
}

class _AssessmentEditorState extends State<_AssessmentEditor> {
  final _qCtrl = TextEditingController();

  ManagerApplicationFileController get c => widget.controller;

  void _submitQuestion() {
    c.addQuestion(_qCtrl.text);
    _qCtrl.clear();
  }

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'manager_apply_assessment_age'.tr,
          textStyle: context.typography.smSemiBold
              .copyWith(color: AppColors.textPrimaryParagraph),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _AgeStepper(
                label: 'manager_apply_assessment_from'.tr,
                value: c.asmtMinAge,
                onChanged: (v) => c.setAssessmentAge(min: v),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _AgeStepper(
                label: 'manager_apply_assessment_to'.tr,
                value: c.asmtMaxAge,
                onChanged: (v) => c.setAssessmentAge(max: v),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _hintRow(context, 'manager_apply_assessment_age_note'.tr),
        SizedBox(height: 16.h),
        AppText(
          text: 'manager_apply_assessment_questions'.tr,
          textStyle: context.typography.smSemiBold
              .copyWith(color: AppColors.textPrimaryParagraph),
        ),
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _qCtrl,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitQuestion(),
                decoration: InputDecoration(
                  hintText: 'manager_apply_assessment_q_hint'.tr,
                  hintStyle: context.typography.smRegular.copyWith(
                      color: AppColors.grayMedium, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _submitQuestion,
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.add_rounded, color: AppColors.white),
              ),
            ),
          ],
        ),
        Obx(() {
          if (c.questions.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: AppText(
                text: 'manager_apply_assessment_empty'.tr,
                textStyle: context.typography.xsRegular
                    .copyWith(color: AppColors.grayMedium),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Column(
              children: [
                for (int i = 0; i < c.questions.length; i++) ...[
                  _QuestionRow(
                    index: i + 1,
                    question: c.questions[i],
                    onRemove: () => c.removeQuestion(c.questions[i].id),
                  ),
                  if (i != c.questions.length - 1) SizedBox(height: 8.h),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _AgeStepper extends StatelessWidget {
  const _AgeStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final RxInt value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          textStyle: context.typography.xsRegular
              .copyWith(color: AppColors.grayMedium),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepBtn(Icons.remove_rounded, () => onChanged(value.value - 1)),
              Obx(
                () => AppText(
                  text:
                      '${value.value} ${'manager_apply_assessment_years'.tr}',
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              _stepBtn(Icons.add_rounded, () => onChanged(value.value + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.primary),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.index,
    required this.question,
    required this.onRemove,
  });

  final int index;
  final AssessmentQuestion question;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(minWidth: 22.w),
                height: 22.w,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AppText(
                  text: '$index',
                  textStyle: context.typography.xsBold
                      .copyWith(color: AppColors.primary, fontSize: 11.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppText(
                  text: question.text,
                  textStyle: context.typography.smRegular.copyWith(
                    color: AppColors.textDefault,
                    height: 1.6,
                  ),
                  maxLines: 10,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded,
                    size: 18.r, color: AppColors.errorForeground),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(right: 32.w),
            child: Row(
              children: [
                for (final key in kAssessmentRatingKeys) ...[
                  _ratingChip(context, 'apply_asmt_$key'.tr),
                  if (key != kAssessmentRatingKeys.last) SizedBox(width: 6.w),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: AppText(
        text: label,
        textStyle: context.typography.xsRegular
            .copyWith(color: AppColors.grayMedium),
      ),
    );
  }
}

Widget _hintRow(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.lightbulb_outline_rounded,
          size: 15.sp, color: AppColors.grayMedium),
      SizedBox(width: 6.w),
      Expanded(
        child: AppText(
          text: text,
          textStyle: context.typography.xsRegular
              .copyWith(color: AppColors.grayMedium, height: 1.5),
          maxLines: 3,
        ),
      ),
    ],
  );
}
