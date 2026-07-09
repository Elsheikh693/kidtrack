import '../../../../index/index_main.dart';
import 'widgets/setup_progress_header.dart';
import 'widgets/setup_group_section.dart';
import 'widgets/setup_finish_bar.dart';
import 'widgets/setup_hub_shimmer.dart';

class SetupChecklistView extends StatefulWidget {
  const SetupChecklistView({super.key});

  @override
  State<SetupChecklistView> createState() => _SetupChecklistViewState();
}

class _SetupChecklistViewState extends State<SetupChecklistView> {
  late final SetupChecklistController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SetupChecklistController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'owner_item_setup_checklist'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: SafeArea(
          top: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SetupHubShimmer();
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                    children: [
                      SetupHubProgressHeader(controller: controller),
                      SizedBox(height: 20.h),
                      ...controller.groups.map(
                        (g) => SetupHubGroupSection(
                          controller: controller,
                          group: g,
                        ),
                      ),
                    ],
                  ),
                ),
                SetupHubFinishBar(controller: controller),
              ],
            );
          }),
        ),
      ),
    );
  }
}
