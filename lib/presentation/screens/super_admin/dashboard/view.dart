import '../../../../index/index_main.dart';

class SuperAdminDashboardView extends StatefulWidget {
  const SuperAdminDashboardView({super.key});

  @override
  State<SuperAdminDashboardView> createState() =>
      _SuperAdminDashboardViewState();
}

class _SuperAdminDashboardViewState extends State<SuperAdminDashboardView> {
  late final SuperAdminDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SuperAdminDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SaHeader(controller: controller),
            SaActionsSection(controller: controller),
          ],
        ),
      ),
    );
  }
}
