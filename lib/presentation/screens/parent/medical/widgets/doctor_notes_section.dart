import '../../../../../index/index_main.dart';

class DoctorNotesSection extends StatelessWidget {
  const DoctorNotesSection({super.key, required this.controller});

  final ParentMedicalController controller;

  @override
  Widget build(BuildContext context) {
    final note = controller.latestDoctorNote;
    if (note == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundInfo50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blueForeground.withValues(alpha: 0.25),
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
                  color: AppColors.blueForeground.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.blueForeground,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'parent_med_doctor_notes_title'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    Text(
                      note.doctorName,
                      style: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  ],
                ),
              ),
              Text(
                note.date,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.blueForeground,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note.note,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textDefault,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
