import '../../../../index/index_main.dart';
import 'widgets/notif_pref_tile.dart';

/// Parent notification-settings sheet — two independent toggles:
///   • attendance (check-in / check-out) — on by default
///   • activities — opt-in, off by default
///
/// Shown once on first app open (via [NotificationPrefsPrompt], right after the
/// mandatory child-details sheet) and thereafter reachable from the parent
/// account screen. In [firstTime] mode it cannot be dismissed without saving.
class NotificationPrefsSheet extends StatefulWidget {
  final bool firstTime;

  const NotificationPrefsSheet({super.key, this.firstTime = false});

  @override
  State<NotificationPrefsSheet> createState() => _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState extends State<NotificationPrefsSheet> {
  late final NotificationPrefsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NotificationPrefsController>();
    // Refresh from the server on every open (fenix keeps the instance alive).
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'notif_prefs_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'notif_prefs_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Obx(
                    () => NotifPrefTile(
                      icon: Icons.login_rounded,
                      iconColor: AppColors.primary,
                      title: 'notif_prefs_attendance_title'.tr,
                      subtitle: 'notif_prefs_attendance_desc'.tr,
                      value: controller.attendance.value,
                      onChanged: (v) => controller.attendance.value = v,
                    ),
                  ),
                  Obx(
                    () => NotifPrefTile(
                      icon: Icons.auto_awesome_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'notif_prefs_activities_title'.tr,
                      subtitle: 'notif_prefs_activities_desc'.tr,
                      value: controller.activities.value,
                      onChanged: (v) => controller.activities.value = v,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.saveAndClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'notif_prefs_save'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                  if (!widget.firstTime)
                    TextButton(
                      onPressed: Get.back,
                      child: Text(
                        'common_cancel'.tr,
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.grayMedium),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the notification-preferences sheet. In [firstTime] mode the sheet is
/// non-dismissible — the parent must press save (which writes the prefs node
/// and clears the first-time prompt).
Future<void> showNotificationPrefsSheet({bool firstTime = false}) {
  return Get.bottomSheet(
    PopScope(
      canPop: !firstTime,
      child: NotificationPrefsSheet(firstTime: firstTime),
    ),
    isScrollControlled: true,
    isDismissible: !firstTime,
    enableDrag: !firstTime,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
  );
}

/// First-open gate for the notification settings. Shows the sheet once — after
/// the mandatory child-profile sheet and before the parent uses the app — when
/// the parent has never saved their preferences (no users/{uid}/notifPrefs node).
class NotificationPrefsPrompt {
  static bool _showing = false;

  static Future<void> maybeShow() async {
    if (_showing) return;
    if (!SessionService().isParent) return;

    // Wait until the child's mandatory profile is complete so the two
    // first-open sheets never stack on top of each other.
    if (!await ChildProfileCompletionPrompt.isActiveChildComplete()) return;

    // Already configured → nothing to prompt.
    if (await NotificationPrefsService().exists()) return;
    if (_showing) return;

    _showing = true;
    await showNotificationPrefsSheet(firstTime: true);
    _showing = false;
  }
}
