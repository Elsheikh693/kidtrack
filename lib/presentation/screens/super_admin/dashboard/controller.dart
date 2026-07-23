import '../../../../index/index_main.dart';

class SuperAdminDashboardController extends GetxController {
  final _session = SessionService();

  String get adminName => _session.currentUser?.displayName ?? 'Super Admin';

  void logout() => showLogoutConfirm();

  void goNurseries() => Get.toNamed(nurseriesView);

  void goPlatformContent() => Get.toNamed(platformContentView);

  void goBilling() => Get.toNamed(platformBillingView);

  void goPaymentAccounts() => Get.toNamed(platformPaymentAccountsView);

  void goCities() => Get.toNamed(citiesView);

  void goTutorialVideos() => Get.toNamed(saTutorialVideosView);

  void goShowcaseAlbums() => Get.toNamed(saShowcaseAlbumsView);

  void goFeedbackCampaigns() => Get.toNamed(kidtrackCampaignsView);
}
