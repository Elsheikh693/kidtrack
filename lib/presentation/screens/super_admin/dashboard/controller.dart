import '../../../../index/index_main.dart';

class SuperAdminDashboardController extends GetxController {
  final _session = SessionService();

  String get adminName => _session.currentUser?.displayName ?? 'Super Admin';

  void logout() => showLogoutConfirm();

  void goNurseries() => Get.toNamed(nurseriesView);

  void goPlatformContent() => Get.toNamed(platformContentView);

  void goBilling() => Get.toNamed(platformBillingView);

  void goCities() => Get.toNamed(citiesView);
}
