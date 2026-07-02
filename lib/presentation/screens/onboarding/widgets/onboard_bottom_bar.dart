import '../../../../index/index_main.dart';
import '../onboard_controller.dart';
import 'onboard_dot.dart';

class OnboardBottomBar extends StatelessWidget {
  const OnboardBottomBar({super.key, required this.controller});

  final OnboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.pages[controller.currentPage.value];
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 28.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (i) => OnboardDot(
                  active: controller.currentPage.value == i,
                  color: page.accentColor,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: controller.next,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: page.accentColor,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: page.accentColor.withValues(alpha: .25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.isLastPage ? 'start_now'.tr : 'next'.tr,
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    if (!controller.isLastPage) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.white,
                        size: 22.sp,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
