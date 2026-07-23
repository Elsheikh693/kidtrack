import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import 'widgets/late_session_settings_sheet.dart';
import 'widgets/manager_schedule_empty.dart';
import 'widgets/manager_slot_card.dart';
import 'widgets/manager_slot_sheet.dart';
import 'widgets/schedule_classroom_bar.dart';
import 'widgets/schedule_day_bar.dart';

/// Manager-owned weekly timetable editor, mounted as a bottom-nav tab.
class ManagerScheduleView extends StatefulWidget {
  const ManagerScheduleView({super.key});

  @override
  State<ManagerScheduleView> createState() => _ManagerScheduleViewState();
}

class _ManagerScheduleViewState extends State<ManagerScheduleView> {
  late final ManagerScheduleController controller;

  static const _accent = AppColors.activityBlue;
  static const _bg = Color(0xFFF6F8FB);

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerScheduleController>();
  }

  void _openSheet([ScheduleModel? existing]) {
    if (controller.selectedClassroom.value == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ManagerSlotSheet(controller: controller, existing: existing),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LateSessionSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(
          title: 'schedule_manager_title'.tr,
          accent: _accent,
          onBack: controller.goBack,
        ),
        Expanded(
          child: ColoredBox(
            color: _bg,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: _accent),
                );
              }
              if (controller.classrooms.isEmpty) {
                return const ManagerScheduleEmpty(noClassrooms: true);
              }
              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _GracePill(controller: controller, onTap: _openSettings),
                        ScheduleClassroomBar(controller: controller),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderNeutralPrimary
                              .withValues(alpha: 0.4),
                          indent: 14.w,
                          endIndent: 14.w,
                        ),
                        ScheduleDayBar(controller: controller),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _SlotList(controller: controller, onEdit: _openSheet),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Compact status pill above the timetable — shows the current grace window and
/// opens the late-session settings sheet on tap.
class _GracePill extends StatelessWidget {
  const _GracePill({required this.controller, required this.onTap});

  final ManagerScheduleController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 12.w, 6.h),
        child: Obx(() {
          final on = controller.lateSettings.enabled.value;
          final grace = controller.lateSettings.graceMinutes.value;
          final color =
              on ? AppColors.activityBlue : AppColors.textSecondaryParagraph;
          return Row(
            children: [
              Icon(
                on
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                size: 15.sp,
                color: color,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  on
                      ? 'late_session_pill_on'.trParams({'m': '$grace'})
                      : 'late_session_pill_off'.tr,
                  style: context.typography.xsMedium.copyWith(color: color),
                ),
              ),
              Icon(Icons.tune_rounded, size: 15.sp, color: color),
            ],
          );
        }),
      ),
    );
  }
}

class _SlotList extends StatelessWidget {
  const _SlotList({required this.controller, required this.onEdit});

  final ManagerScheduleController controller;
  final void Function(ScheduleModel?) onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final slots = controller.currentSlots;
          if (slots.isEmpty) return const ManagerScheduleEmpty();
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 120.h),
            itemCount: slots.length,
            itemBuilder: (_, i) => ManagerSlotCard(
              slot: slots[i],
              controller: controller,
              onTap: () => onEdit(slots[i]),
            ),
          );
        }),
        // Clear the floating bottom nav bar (~68h bar + margin + safe area).
        Positioned(
          left: 20.w,
          bottom: 100.h,
          child: FloatingActionButton.extended(
            heroTag: 'schedule_add_fab',
            backgroundColor: AppColors.activityBlue,
            elevation: 3,
            onPressed: () => onEdit(null),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'schedule_add'.tr,
              style: context.typography.smSemiBold.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
