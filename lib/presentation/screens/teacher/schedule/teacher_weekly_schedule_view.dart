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
                                    // Read-only for teachers: the manager owns
                                    // the timetable, so no edit/delete callbacks.
                                    return ScheduleSlotCard(
                                      slot: slot,
                                      controller: controller,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
