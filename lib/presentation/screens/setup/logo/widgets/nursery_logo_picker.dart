import '../../../../../index/index_main.dart';

/// Tappable circular logo well: shows the current logo or an add-photo
/// placeholder, with a small camera badge overlaid at the corner. Tapping
/// picks + uploads a new logo via the controller.
class NurseryLogoPicker extends StatelessWidget {
  const NurseryLogoPicker({super.key, required this.controller});

  final NurseryLogoController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickLogo,
      child: Obx(() {
        final hasLogo = controller.logo.value != null;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary10, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: hasLogo
                  ? AppNetworkImage(
                      url: controller.logo.value,
                      width: 160.w,
                      height: 160.w,
                    )
                  : Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primary,
                      size: 44.r,
                    ),
            ),
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: Icon(
                  hasLogo ? Icons.edit_rounded : Icons.add_rounded,
                  color: AppColors.white,
                  size: 22.r,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
