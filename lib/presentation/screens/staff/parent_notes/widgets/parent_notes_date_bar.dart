import '../../../../../index/index_main.dart';

/// Date filter for the guardian-notes inbox: a chip that opens the shared date
/// picker (past days) plus a quick "all days" reset.
class ParentNotesDateBar extends StatelessWidget {
  const ParentNotesDateBar({super.key, required this.controller});

  final ParentNotesInboxController controller;

  static const _accent = Color(0xFF6C4DDB);

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      minimumDate: DateTime.now().subtract(const Duration(days: 120)),
      maximumDate: DateTime.now(),
    );
    if (picked != null) controller.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pick(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accent.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 15, color: _accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          text: controller.formattedDate,
                          textStyle: context.typography.smMedium.copyWith(
                            color: _accent,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded,
                          size: 18, color: _accent),
                    ],
                  ),
                ),
              ),
            ),
            if (controller.selectedDate.value != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: controller.clearDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundNeutral100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    text: 'parent_notes_all_days'.tr,
                    textStyle: context.typography.smMedium.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
