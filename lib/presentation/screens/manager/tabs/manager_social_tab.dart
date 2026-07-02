import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';

class ManagerSocialTab extends StatelessWidget {
  const ManagerSocialTab({super.key});

  static const _accent = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(
          title: 'manager_tab_social'.tr,
          accent: _accent,
          onBack: () => Get.find<MainPageViewModel>().changePage(0),
        ),
        const Expanded(child: OwnerFeedTab(showHeader: false)),
      ],
    );
  }
}
