import '../../../../../index/index_main.dart';
import 'add_branch_manager_sheet.dart';
import 'setup_branch_tile.dart';

class BranchesStep extends StatelessWidget {
  final OwnerSetupController controller;
  const BranchesStep({super.key, required this.controller});

  void _showAddSheet() {
    Get.bottomSheet(
      AddBranchManagerSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.branches;
      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(onAdd: _showAddSheet),
            SizedBox(height: 20.h),
            if (list.isEmpty)
              _EmptyBranches()
            else
              ...list.map((b) {
                final manager = controller.managerForBranch(b.key);
                return SetupBranchTile(
                  branch: b,
                  managerName: manager?.name,
                  phone: manager?.phone,
                  onDelete: () => controller.deleteBranch(b.key ?? ''),
                  onSetMain: () => controller.setMainBranch(b.key ?? ''),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _StepHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _StepHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('setup_step_branches'.tr,
                  style: context.typography.mdBold.copyWith(
                      fontSize: 17, color: const Color(0xFF1F2937))),
              Text('setup_branches_subtitle'.tr,
                  style: context.typography.xsRegular.copyWith(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add_rounded, size: 18.sp),
          label: Text('setup_add_branch'.tr),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E35B1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _EmptyBranches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Column(
          children: [
            Icon(Icons.location_city_outlined,
                size: 56.sp, color: const Color(0xFFD1D5DB)),
            SizedBox(height: 12.h),
            Text('setup_branches_empty'.tr,
                style: context.typography.smSemiBold.copyWith(
                    fontSize: 15, color: const Color(0xFF9CA3AF))),
            SizedBox(height: 4.h),
            Text('setup_branches_empty_hint'.tr,
                style: context.typography.xsRegular.copyWith(
                    fontSize: 12, color: const Color(0xFFD1D5DB))),
          ],
        ),
      ),
    );
  }
}
