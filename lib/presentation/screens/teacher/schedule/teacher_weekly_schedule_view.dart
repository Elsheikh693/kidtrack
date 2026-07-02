import '../../../../index/index_main.dart';

class TeacherWeeklyScheduleView extends StatefulWidget {
  const TeacherWeeklyScheduleView({super.key});

  @override
  State<TeacherWeeklyScheduleView> createState() =>
      _TeacherWeeklyScheduleViewState();
}

class _TeacherWeeklyScheduleViewState
    extends State<TeacherWeeklyScheduleView> {
  late final TeacherWeeklyScheduleController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherWeeklyScheduleController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'teacher_schedule_title'.tr,
          style: context.typography.displaySmBold
              .copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.activityGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.activityGreen,
                ),
              )
            : controller.myClassrooms.isEmpty
                ? const ScheduleNoClassroomsSection()
                : Column(
                    children: [
                      ScheduleFilterBar(controller: controller),
                      Expanded(
                        child: Obx(
                          () => controller.currentSlots.isEmpty
                              ? const ScheduleEmptySection()
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 100,
                                  ),
                                  itemCount: controller.currentSlots.length,
                                  itemBuilder: (_, i) {
                                    final slot = controller.currentSlots[i];
                                    return ScheduleSlotCard(
                                      slot: slot,
                                      controller: controller,
                                      onEdit: () => _showSheet(
                                        context,
                                        existing: slot,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, slot),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: Obx(
        () => controller.myClassrooms.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => _showSheet(context),
                backgroundColor: AppColors.activityGreen,
                elevation: 2,
                icon: const Icon(Icons.add_rounded, color: AppColors.white),
                label: Text(
                  'schedule_add_fab'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
      ),
    );
  }

  void _showSheet(BuildContext context, {ScheduleModel? existing}) {
    Get.bottomSheet(
      ScheduleEntrySheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(BuildContext context, ScheduleModel slot) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('schedule_delete'.tr),
        content: Text('teacher_schedule_delete_confirm'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('teacher_schedule_cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSlot(slot);
            },
            child: Text(
              'schedule_delete'.tr,
              style: const TextStyle(color: AppColors.activityRed),
            ),
          ),
        ],
      ),
    );
  }
}
