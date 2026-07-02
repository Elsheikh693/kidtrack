import '../../../../index/index_main.dart';
import '../../../screens/shared/edit_profile_sheet.dart';
import '../../../screens/shared/language_sheet.dart';
import '../../../screens/shared/contact_sheet.dart';

class ParentAccountController extends GetxController {
  late final SessionService _session;

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
  }

  String get parentName =>
      _session.currentUser?.displayName ?? 'parent_default_name'.tr;
  String get parentPhone => _session.currentUser?.phone ?? '01xxxxxxxxx';

  // ─── Navigation ───────────────────────────────────────────────────────────

  void editProfile() => showEditProfileSheet(isStaff: false);

  void navigateToRequestsHistory() =>
      Get.toNamed(parentRequestsHistoryView);

  void navigateToPickup() => Get.toNamed(authorizedPickupView);

  void navigateToFinance() => Get.toNamed(parentInvoicesView);

  void navigateToChat() => openParentChat();

  void navigateToHomeLocation() => Get.toNamed(parentHomeLocationView);

  void navigateToNotifications() => Get.toNamed(notificationsView);

  void changeTheme() {
    Get.snackbar(
      'theme_sheet_title'.tr,
      'theme_dark_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.white,
      colorText: AppColors.textDefault,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void contactNursery() => showContactSheet(ContactType.nursery);

  void contactAdmin() => showContactSheet(ContactType.admin);

  void contactSupport() => showContactSheet(ContactType.support);

  void logout() => showLogoutConfirm();
}
