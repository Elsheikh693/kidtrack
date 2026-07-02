import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';
import 'staff_search_bar.dart';
import 'staff_role_filter_bar.dart';
import 'staff_directory_tile.dart';
import 'staff_profile_sheet.dart';

/// The full searchable, role-filterable list of active staff.
class StaffDirectorySection extends StatelessWidget {
  const StaffDirectorySection({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => ManagerSectionHeader(
            title: 'manager_staff_directory_title'.tr,
            icon: Icons.groups_rounded,
            color: AppColors.activityBlue,
            trailing: '${controller.totalStaff.value}',
          ),
        ),
        StaffSearchBar(controller: controller),
        const SizedBox(height: 12),
        StaffRoleFilterBar(controller: controller),
        const SizedBox(height: 12),
        Obx(() {
          final items = controller.filteredDirectory;
          if (items.isEmpty) return _EmptyDirectory();
          return Column(
            children: items
                .map((s) => StaffDirectoryTile(
                      staff: s,
                      status: controller.attendanceStatus(s.key ?? ''),
                      onTap: () => Get.bottomSheet(
                        StaffProfileSheet(staff: s),
                        isScrollControlled: true,
                      ),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _EmptyDirectory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 34, color: AppColors.grayMedium),
          const SizedBox(height: 10),
          Text(
            'manager_staff_directory_empty'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
