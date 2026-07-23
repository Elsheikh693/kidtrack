import '../../index/index_main.dart';

export 'package:image_picker/image_picker.dart' show ImageSource;

/// Bottom sheet that lets the user choose whether to add a photo by taking a
/// new one with the camera or picking existing ones from the gallery. Returns
/// the chosen [ImageSource], or `null` if the user dismissed the sheet.
///
/// Shared by every photo-upload flow (activity photos, event photos, …) so the
/// camera option stays consistent everywhere.
Future<ImageSource?> showImageSourceSheet() {
  return Get.bottomSheet<ImageSource>(
    const _ImageSourceSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderNeutralPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppText(
                text: 'image_source_title'.tr,
                textStyle: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              const SizedBox(height: 16),
              _option(
                context,
                icon: Icons.photo_camera_rounded,
                label: 'image_source_camera'.tr,
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _option(
                context,
                icon: Icons.photo_library_rounded,
                label: 'image_source_gallery'.tr,
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            AppText(
              text: label,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
