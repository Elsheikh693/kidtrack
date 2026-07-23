import '../../../../index/index_main.dart';
import 'widgets/apply_step_branch.dart';
import 'widgets/apply_step_terms.dart';
import 'widgets/apply_dynamic_section.dart';
import 'widgets/apply_step_assessment.dart';
import 'widgets/apply_step_bus.dart';
import 'widgets/apply_step_notes.dart';
import 'widgets/apply_step_review.dart';

class OnlineApplicationView extends StatefulWidget {
  const OnlineApplicationView({super.key});

  @override
  State<OnlineApplicationView> createState() => _OnlineApplicationViewState();
}

class _OnlineApplicationViewState extends State<OnlineApplicationView> {
  late final OnlineApplicationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OnlineApplicationController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: Obx(() => PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          controller.steps.map(_buildStep).toList(),
                    )),
              ),
              _bottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ApplyStepType type) {
    switch (type) {
      case ApplyStepType.branch:
        return ApplyStepBranch(controller: controller);
      case ApplyStepType.terms:
        return ApplyStepTerms(controller: controller);
      case ApplyStepType.child:
        return ApplyDynamicSection(
          controller: controller,
          type: ApplyFormSectionType.childInfo,
          icon: Icons.child_care_rounded,
          titleKey: 'apply_step_child_title',
          subtitleKey: 'apply_step_child_sub',
        );
      case ApplyStepType.assessment:
        return ApplyStepAssessment(controller: controller);
      case ApplyStepType.father:
        return ApplyDynamicSection(
          controller: controller,
          type: ApplyFormSectionType.fatherInfo,
          icon: Icons.man_rounded,
          titleKey: 'apply_step_father_title',
          subtitleKey: 'apply_step_guardian_sub',
        );
      case ApplyStepType.mother:
        return ApplyDynamicSection(
          controller: controller,
          type: ApplyFormSectionType.motherInfo,
          icon: Icons.woman_rounded,
          titleKey: 'apply_step_mother_title',
          subtitleKey: 'apply_step_guardian_sub',
        );
      case ApplyStepType.bus:
        return ApplyStepBus(controller: controller);
      case ApplyStepType.notes:
        return ApplyStepNotes(controller: controller);
      case ApplyStepType.review:
        return ApplyStepReview(controller: controller);
    }
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textDefault,
              ),
              Expanded(
                child: AppText(
                  text: 'apply_title'.tr,
                  textStyle: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Obx(() => Row(
                children: List.generate(
                  controller.stepCount,
                  (i) => Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: i <= controller.currentStep.value
                            ? AppColors.primary
                            : AppColors.grayLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, 12.h, 20.w, 12.h + MediaQuery.of(context).padding.bottom),
      color: AppColors.white,
      child: Obx(() {
        final isLast =
            controller.currentStep.value == controller.stepCount - 1;
        return Row(
          children: [
            if (controller.currentStep.value > 0)
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: GestureDetector(
                  onTap: controller.prevStep,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: AppColors.primary, size: 20.sp),
                  ),
                ),
              ),
            Expanded(
              child: PrimaryTextButton(
                appButtonSize: AppButtonSize.xlarge,
                onTap: isLast ? controller.submit : controller.nextStep,
                label: AppText(
                  text: isLast ? 'apply_submit_btn'.tr : 'apply_next_btn'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
