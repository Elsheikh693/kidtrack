import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

class ApplyStepReview extends StatelessWidget {
  final OnlineApplicationController controller;
  const ApplyStepReview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        const ApplyStepHeader(
          icon: Icons.fact_check_rounded,
          titleKey: 'apply_step_review_title',
          subtitleKey: 'apply_step_review_sub',
        ),
        Obx(() => _card(context, 'apply_step_branch_title', [
              _row(context, 'apply_review_branch',
                  controller.selectedBranchName.value ?? ''),
              ...controller.branchPackages
                  .where((p) => controller.selectedPackageIds.contains(p.key))
                  .map((p) => _row(context, p.name,
                      '${_money(p.price)} ${'currency'.tr}')),
              _row(context, 'apply_total_label',
                  '${_money(controller.selectedTotal)} ${'currency'.tr}'),
            ])),
        _card(context, 'apply_step_child_title', [
          _row(context, 'apply_field_full_name', controller.childName.text),
        ]),
        _card(context, 'apply_step_father_title', [
          _row(context, 'apply_field_full_name', controller.fatherName.text),
          _row(context, 'apply_field_phone', controller.fatherPhone.text),
        ]),
        _card(context, 'apply_step_mother_title', [
          _row(context, 'apply_field_full_name', controller.motherName.text),
          _row(context, 'apply_field_phone', controller.motherPhone.text),
        ]),
        Obx(() => controller.wantsBus.value
            ? _card(context, 'apply_step_bus_title', [
                _row(context, 'apply_bus_address', controller.busAddress.text),
              ])
            : const SizedBox.shrink()),
        SizedBox(height: 20.h),
      ],
    );
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Widget _card(BuildContext context, String titleKey, List<Widget> rows) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: titleKey.tr,
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 8.h),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String labelKey, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          AppText(
            text: '${labelKey.tr}: ',
            textStyle: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          Expanded(
            child: AppText(
              text: value.trim().isEmpty ? '—' : value.trim(),
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textDefault),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
