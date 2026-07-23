import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_item_tile.dart';
import 'setup_shared_widgets.dart';

class ClassroomsStep extends StatelessWidget {
  final ManagerSetupController controller;
  const ClassroomsStep({super.key, required this.controller});

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => _AddClassroomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SetupStepScaffold(
          icon: Icons.meeting_room_rounded,
          iconBg: const Color(0xFFD1FAE5),
          iconColor: const Color(0xFF059669),
          title: 'setup_step_classrooms'.tr,
          subtitle: 'setup_classrooms_subtitle'.tr,
          onAdd: () => _showAdd(context),
          addLabel: 'setup_add_classroom'.tr,
          emptyIcon: Icons.meeting_room_outlined,
          emptyLabel: 'setup_classrooms_empty'.tr,
          items: controller.classrooms
              .map((c) => SetupItemTile(
                    icon: Icons.meeting_room_rounded,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF059669),
                    title: c.name,
                    subtitle: c.capacity != null
                        ? '${'setup_classroom_capacity'.tr}: ${c.capacity}'
                        : null,
                    onDelete: () => controller.deleteClassroom(c.key ?? ''),
                  ))
              .toList(),
        ));
  }
}

class _AddClassroomSheet extends StatefulWidget {
  final ManagerSetupController controller;
  const _AddClassroomSheet({required this.controller});
  @override
  State<_AddClassroomSheet> createState() => _AddClassroomSheetState();
}

class _AddClassroomSheetState extends State<_AddClassroomSheet> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('setup_classroom_name_required'.tr);
      return;
    }
    Get.back();
    widget.controller.addClassroom(name);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('setup_add_classroom_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),
              SetupSheetLabel('setup_classroom_name_label'.tr),
              SizedBox(height: 6.h),
              SetupSheetField(
                  controller: _nameCtrl,
                  hint: 'setup_classroom_name_hint'.tr),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text('setup_add_btn'.tr,
                      style: context.typography.smSemiBold
                          .copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

