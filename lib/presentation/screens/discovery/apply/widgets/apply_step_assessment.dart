import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

/// Conditional wizard step shown only when the child's age falls in the
/// nursery's configured band. Renders the manager's dynamic assessment
/// questions, each rated on the fixed always/sometimes/never scale, plus notes.
class ApplyStepAssessment extends StatefulWidget {
  final OnlineApplicationController controller;
  const ApplyStepAssessment({super.key, required this.controller});

  @override
  State<ApplyStepAssessment> createState() => _ApplyStepAssessmentState();
}

class _ApplyStepAssessmentState extends State<ApplyStepAssessment>
    with KeyboardSheetMixin {
  late final FocusNode _notesFocus;

  @override
  void initState() {
    super.initState();
    _notesFocus = kbNode();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return wrapWithKeyboard(
      context: context,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          const ApplyStepHeader(
            icon: Icons.assignment_turned_in_rounded,
            titleKey: 'apply_step_asmt_title',
            subtitleKey: 'apply_step_asmt_sub',
          ),
          _legend(context),
          SizedBox(height: 14.h),
          ...controller.assessmentQuestions
              .map((q) => _itemRow(context, controller, q)),
          SizedBox(height: 16.h),
          ApplyField(
            controller: controller.assessmentNotes,
            labelKey: 'apply_asmt_notes',
            maxLines: 3,
            focusNode: _notesFocus,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: 'apply_asmt_legend'.tr,
        textStyle: context.typography.xsRegular
            .copyWith(color: AppColors.primary, height: 1.6),
        maxLines: 3,
      ),
    );
  }

  Widget _itemRow(BuildContext context, OnlineApplicationController controller,
      AssessmentQuestion item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: item.text,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.textDefault, height: 1.5),
            maxLines: 4,
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final selected = controller.assessmentRatings[item.id];
            return Row(
              children: kAssessmentRatingKeys.map((r) {
                final isSel = selected == r;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setAssessmentRating(item.id, r),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        text: 'apply_asmt_$r'.tr,
                        textStyle: context.typography.xsMedium.copyWith(
                          color: isSel ? AppColors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
