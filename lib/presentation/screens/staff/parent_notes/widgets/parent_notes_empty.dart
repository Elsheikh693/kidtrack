import '../../../../../index/index_main.dart';

/// Shown when no guardian notes match the current scope / date filter.
class ParentNotesEmpty extends StatelessWidget {
  const ParentNotesEmpty({super.key});

  static const _accent = Color(0xFF6C4DDB);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.forum_outlined,
                  size: 40, color: _accent),
            ),
            const SizedBox(height: 18),
            AppText(
              text: 'parent_notes_empty_title'.tr,
              textStyle: context.typography.mdBold.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              text: 'parent_notes_empty_sub'.tr,
              textAlign: TextAlign.center,
              textStyle: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
