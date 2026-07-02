import '../../../../../index/index_main.dart';

class ParentLeaveEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const ParentLeaveEmpty({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 48, color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'parent_req_empty_title'.tr,
              style: context.typography.lgBold.copyWith(
                  color: AppColors.textDefault),
            ),
            const SizedBox(height: 8),
            Text(
              'parent_req_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('parent_req_add'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
