import 'package:chewie/chewie.dart';

import '../../../../index/index_main.dart';

class TutorialPlayerView extends StatefulWidget {
  const TutorialPlayerView({super.key});

  @override
  State<TutorialPlayerView> createState() => _TutorialPlayerViewState();
}

class _TutorialPlayerViewState extends State<TutorialPlayerView> {
  late final TutorialPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TutorialPlayerController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlack,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.white),
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.white, size: 22.sp),
          ),
          title: AppText(
            text: controller.video.title,
            textStyle: context.typography.mdBold.copyWith(color: AppColors.white),
          ),
        ),
        body: Center(
          child: Obx(() {
            if (controller.hasError.value) {
              return _ErrorState(controller: controller);
            }
            if (!controller.isReady.value ||
                controller.chewieController == null) {
              return CircularProgressIndicator(color: AppColors.white);
            }
            return AspectRatio(
              aspectRatio:
                  controller.chewieController!.videoPlayerController.value.aspectRatio,
              child: Chewie(controller: controller.chewieController!),
            );
          }),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final TutorialPlayerController controller;
  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.white.withValues(alpha: 0.7), size: 44.sp),
          SizedBox(height: 14.h),
          AppText(
            text: 'tutorial_play_error'.tr,
            textStyle:
                context.typography.smSemiBold.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          if (controller.errorDetail.value.isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              text: controller.errorDetail.value,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.white.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
          ],
          SizedBox(height: 20.h),
          OutlinedButton.icon(
            onPressed: controller.load,
            icon: Icon(Icons.refresh_rounded, color: AppColors.white, size: 18.sp),
            label: AppText(
              text: 'tutorial_retry'.tr,
              textStyle:
                  context.typography.smSemiBold.copyWith(color: AppColors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.white.withValues(alpha: 0.4)),
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }
}
