import '../../../../../index/index_main.dart';

class MedicalInfoCard extends StatelessWidget {
  const MedicalInfoCard({super.key, required this.controller});

  final ParentMedicalController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_information_outlined,
                color: AppColors.blueForeground,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'parent_med_info_card_title'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.errorForeground.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.errorForeground.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bloodtype_outlined,
                      color: AppColors.errorForeground,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${'parent_med_blood_type'.tr}: ${controller.bloodType}',
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.errorForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.medication_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'parent_med_medications_title'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (controller.medications.isEmpty)
            Text(
              'parent_med_no_medications'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            )
          else
            ...controller.medications.map(
              (med) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        med,
                        style: context.typography.smRegular
                            .copyWith(color: AppColors.textDefault),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.emergency_outlined,
                color: AppColors.errorForeground,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'parent_med_emergency_notes'.tr,
                style: context.typography.smMedium
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.emergencyNotes ?? 'parent_med_no_emergency_notes'.tr,
            style: context.typography.xsRegular.copyWith(
              color: controller.emergencyNotes != null
                  ? AppColors.textDefault
                  : AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
