import '../../../../index/index_main.dart';

class OverdueView extends StatefulWidget {
  const OverdueView({super.key});

  @override
  State<OverdueView> createState() => _OverdueViewState();
}

class _OverdueViewState extends State<OverdueView> {
  late final OverdueController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => OverdueController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'finance_dashboard_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: OverdueDashboard(
          controller: controller,
          headerSliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ),
    );
  }
}
