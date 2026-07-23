import '../../../../index/index_main.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_section_widget.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  late final OwnerDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => OwnerDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            DashboardHeader(controller: controller),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) =>
                      DashboardSectionWidget(section: controller.sections[i]),
                  childCount: controller.sections.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
