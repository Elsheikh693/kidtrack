import '../../../index/index_main.dart';
import 'widgets/tutorial_progress_header.dart';
import 'widgets/tutorial_step_tile.dart';
import 'widgets/tutorial_empty.dart';
import 'widgets/tutorial_shimmer.dart';

class AppTutorialView extends StatefulWidget {
  const AppTutorialView({super.key});

  @override
  State<AppTutorialView> createState() => _AppTutorialViewState();
}

class _AppTutorialViewState extends State<AppTutorialView> {
  late final AppTutorialController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppTutorialController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.textDefault, size: 22.sp),
          ),
          title: AppText(
            text: 'tutorial_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const TutorialShimmer();
          if (controller.videos.isEmpty) return const TutorialEmpty();
          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            children: [
              TutorialProgressHeader(controller: controller),
              SizedBox(height: 22.h),
              for (int i = 0; i < controller.videos.length; i++)
                TutorialStepTile(
                  controller: controller,
                  index: i,
                  isFirst: i == 0,
                  isLast: i == controller.videos.length - 1,
                ),
            ],
          );
        }),
      ),
    );
  }
}
