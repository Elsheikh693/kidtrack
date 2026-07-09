import '../../../../../index/index_main.dart';

class SetupHubFinishBar extends StatelessWidget {
  final SetupChecklistController controller;
  const SetupHubFinishBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grayLight)),
      ),
      child: Obx(() {
        final ready = controller.allDone;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ready)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  'setup_hub_finish_hint'.tr,
                  textAlign: TextAlign.center,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ready ? controller.finish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'setup_hub_finish'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
