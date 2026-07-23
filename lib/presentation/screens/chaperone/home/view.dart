import '../../../../index/index_main.dart';
import 'widgets/tracking_status_bar.dart';
import 'widgets/children_list_section.dart';
import 'widgets/direction_selector.dart';

class ChaperoneHomeView extends StatefulWidget {
  const ChaperoneHomeView({super.key});

  @override
  State<ChaperoneHomeView> createState() => _ChaperoneHomeViewState();
}

class _ChaperoneHomeViewState extends State<ChaperoneHomeView> {
  late final ChaperoneHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChaperoneHomeController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'tracking_chaperone_title'.tr),
        body: ListView(
          children: [
            DirectionSelector(controller: controller),
            TrackingStatusBar(controller: controller),
            ChildrenListSection(controller: controller),
          ],
        ),
      ),
    );
  }
}
