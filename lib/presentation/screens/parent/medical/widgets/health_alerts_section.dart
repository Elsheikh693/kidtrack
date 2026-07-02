import '../../../../../index/index_main.dart';

class HealthAlertsSection extends StatelessWidget {
  const HealthAlertsSection({super.key, required this.controller});

  final ParentMedicalController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWarningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.yellowForeground.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.yellowForeground.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.yellowForeground,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'parent_med_alerts_title'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
            ],
          ),
          if (!controller.hasAlerts) ...[
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.successForeground,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'parent_med_no_alerts'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (controller.allergies.isNotEmpty) ...[
              const SizedBox(height: 14),
              _AlertGroup(
                labelKey: 'parent_med_allergies_title',
                items: controller.allergies,
                dotColor: const Color(0xFFD97706),
              ),
            ],
            if (controller.conditions.isNotEmpty) ...[
              const SizedBox(height: 10),
              _AlertGroup(
                labelKey: 'parent_med_conditions_title',
                items: controller.conditions,
                dotColor: AppColors.errorForeground,
              ),
            ],
            if (controller.specialNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              _AlertGroup(
                labelKey: 'parent_med_special_notes_title',
                items: controller.specialNotes,
                dotColor: AppColors.blueForeground,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AlertGroup extends StatelessWidget {
  const _AlertGroup({
    required this.labelKey,
    required this.items,
    required this.dotColor,
  });

  final String labelKey;
  final List<String> items;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr,
          style: context.typography.xsRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: context.typography.smRegular
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
