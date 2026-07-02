import '../../../index/index_main.dart';
import 'widgets/onboard_data.dart';

class OnboardController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  List<OnboardData> get pages => [
    OnboardData(
      heroIcon: Icons.child_care_rounded,
      satellites: [
        OnboardSatellite(Icons.school_rounded, AppColors.activityPurple),
        OnboardSatellite(Icons.groups_rounded, AppColors.activityBlue),
        OnboardSatellite(Icons.favorite_rounded, AppColors.secondary80),
      ],
      chip: 'onboard_chip_1'.tr,
      title: 'onboard_title_1'.tr,
      subtitle: 'onboard_subtitle_1'.tr,
      accentColor: AppColors.primary,
      accentColor2: AppColors.primary60,
      accentLight: AppColors.primary10,
    ),
    OnboardData(
      heroIcon: Icons.event_available_rounded,
      satellites: [
        OnboardSatellite(
            Icons.restaurant_rounded, AppColors.activityAmberBrand),
        OnboardSatellite(Icons.bedtime_rounded, AppColors.activityPurple),
        OnboardSatellite(
            Icons.directions_walk_rounded, AppColors.activityGreen),
        OnboardSatellite(Icons.checklist_rounded, AppColors.activityBlue),
      ],
      chip: 'onboard_chip_2'.tr,
      title: 'onboard_title_2'.tr,
      subtitle: 'onboard_subtitle_2'.tr,
      accentColor: AppColors.secondary80,
      accentColor2: AppColors.secondary60,
      accentLight: AppColors.secondary10,
    ),
    OnboardData(
      heroIcon: Icons.notifications_active_rounded,
      satellites: [
        OnboardSatellite(Icons.photo_camera_rounded, AppColors.activityOrange),
        OnboardSatellite(Icons.chat_bubble_rounded, AppColors.activityBlue),
        OnboardSatellite(Icons.verified_user_rounded, AppColors.activityGreen),
      ],
      chip: 'onboard_chip_3'.tr,
      title: 'onboard_title_3'.tr,
      subtitle: 'onboard_subtitle_3'.tr,
      accentColor: AppColors.activityGreen,
      accentColor2: AppColors.teal,
      accentLight: AppColors.activityGreenLight,
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (isLastPage) {
      finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> finish() async {
    await OnboardLocalCheck.markSeen();
    Get.offAllNamed(nurseryDiscoveryView);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
