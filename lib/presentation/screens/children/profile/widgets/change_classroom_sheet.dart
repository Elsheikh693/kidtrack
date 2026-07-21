import '../../../../../index/index_main.dart';
import 'manage_sheet_scaffold.dart';

/// Bottom sheet listing the active classrooms in the child's branch so an
/// enrollment-managing user can move them to a different one.
class ChangeClassroomSheet extends StatelessWidget {
  const ChangeClassroomSheet({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ManageSheetScaffold(
      icon: Icons.class_rounded,
      title: 'child_manage_classroom_title'.tr,
      child: Obx(() {
        if (controller.isManageLoading.value) {
          return const ManageSheetLoader();
        }
        final child = controller.child.value;
        if (child == null) return const SizedBox.shrink();
        final classrooms = controller.classroomsFor(child.branchId);
        if (classrooms.isEmpty) {
          return ManageSheetEmpty(text: 'child_change_no_classrooms'.tr);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: classrooms
              .map((c) => ManageSheetTile(
                    label: c.name,
                    selected: c.key == child.classroomId,
                    onTap: () => controller.changeClassroom(c),
                  ))
              .toList(),
        );
      }),
    );
  }
}

/// Loads the lookup options, then opens the change-classroom sheet.
Future<void> showChangeClassroomSheet(ChildProfileController controller) {
  controller.loadManageLookups();
  return showManageSheet(ChangeClassroomSheet(controller: controller));
}
