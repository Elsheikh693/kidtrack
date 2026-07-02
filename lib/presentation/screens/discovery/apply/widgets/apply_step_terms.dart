import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

class ApplyStepTerms extends StatelessWidget {
  final OnlineApplicationController controller;
  const ApplyStepTerms({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final terms = controller.nursery.terms;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        const ApplyStepHeader(
          icon: Icons.description_rounded,
          titleKey: 'apply_step_terms_title',
          subtitleKey: 'apply_step_terms_sub',
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: terms.isEmpty
              ? AppText(
                  text: 'apply_terms_empty'.tr,
                  textStyle: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph, height: 1.8),
                  maxLines: 1000,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < terms.length; i++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 7.h),
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: AppText(
                              text: terms[i],
                              textStyle: context.typography.smRegular.copyWith(
                                  color: AppColors.textDefault, height: 1.8),
                              maxLines: 1000,
                            ),
                          ),
                        ],
                      ),
                      if (i != terms.length - 1) SizedBox(height: 12.h),
                    ],
                  ],
                ),
        ),
        Obx(() => GestureDetector(
              onTap: () => controller.toggleAgreed(!controller.agreed.value),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: controller.agreed.value
                      ? AppColors.primaryLight
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: controller.agreed.value
                        ? AppColors.primary
                        : AppColors.grayLight,
                    width: controller.agreed.value ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      controller.agreed.value
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AppText(
                        text: 'apply_terms_agree'.tr,
                        textStyle: context.typography.smRegular.copyWith(
                            color: AppColors.textDefault, height: 1.6),
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        SizedBox(height: 20.h),
      ],
    );
  }
}
