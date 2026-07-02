import '../../../../index/index_main.dart';
import '../onboard_controller.dart';

class OnboardSkipButton extends StatelessWidget {
  const OnboardSkipButton({super.key, required this.controller});

  final OnboardController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Obx(
        () => AnimatedOpacity(
          opacity: controller.isLastPage ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: GestureDetector(
            onTap: controller.finish,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.borderNeutralPrimary.withValues(alpha: .15),
                ),
              ),
              child: Text(
                'skip'.tr,
                style: context.typography.smMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
