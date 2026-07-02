import '../../../index/index_main.dart';
import 'widgets/notif_settings_banner.dart';
import 'widgets/notif_settings_header.dart';
import 'widgets/notif_toggles_card.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  late final NotificationSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NotificationSettingsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const NotifSettingsHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notif_settings_section'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textSecondaryParagraph,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    NotifTogglesCard(controller: controller),
                    SizedBox(height: 28.h),
                    const NotifSettingsBanner(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
